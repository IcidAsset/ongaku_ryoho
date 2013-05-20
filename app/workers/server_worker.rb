require "net/http"

class ServerWorker
  include Sidekiq::Worker

  def perform(user_id, server_id, method_name)
    server = Server.find(server_id, conditions: { user_id: user_id })

    if server
      begin
        ServerWorker.send(method_name.to_sym, server)
      rescue
        server.remove_from_redis_queue(method_name.to_s.chomp("_tracks"))
        puts "ServerWorker could not process job!"
      end
    else
      puts "Server instance not found!"
    end
  end


  def self.process_tracks(server)
    begin
      uri = URI.parse(server.configuration["location"])
      response = Net::HTTP.get(uri)
    rescue
      server.remove_from_redis_queue(:process)
      return
    end

    # parse json
    tracks = JSON.parse(response)

    # put them tracks in them database
    Server.add_new_tracks(server, tracks)

    # the end
    server.processed = true
    server.save
    server.remove_from_redis_queue(:process)
  end


  # check if there is any music added or removed from the server
  # and then add and/or remove from the database
  def self.check_tracks(server)
    file_list = server.tracks.all.map(&:location)

    # get json data from server
    begin
      uri = URI.parse(server.configuration["location"] + "check")
      response = Net::HTTP.post_form(uri, { file_list: file_list.to_json })
    rescue
      server.remove_from_redis_queue(:check)
      return
    end

    # parse json
    parsed_response = JSON.parse(response.body)
    missing_files = parsed_response["missing_files"]
    new_tracks = parsed_response["new_tracks"]

    # missing files
    Server.remove_tracks(server, missing_files)

    # new_tracks
    Server.add_new_tracks(server, new_tracks)

    # if changed
    if missing_files.present? or new_tracks.present?
      server.updated_at = Time.now
      server.save
    end

    # remove from redis queue
    server.remove_from_redis_queue(:check)
  end
end
