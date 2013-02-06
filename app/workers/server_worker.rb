require "net/http"

class ServerWorker
  include Sidekiq::Worker

  def perform(user_id, server_id, method_name)
    begin
      server = Server.find(server_id, conditions: { user_id: user_id })
      ServerWorker.send(method_name.to_sym, server) if server
    rescue
      puts "Server instance not found!"
    end
  end


  def self.process_tracks(server)
    args = [:process]

    begin
      uri = URI.parse(server.configuration[:location])
      response = Net::HTTP.get(uri)
    rescue
      args.unshift "unprocessed / server not found"
      server.set_definite_status(*args)
      return
    end

    # parse json
    tracks = JSON.parse(response)

    # no music =(
    if tracks.empty?
      args.unshift "unprocessed / no music found"
      server.set_definite_status(*args)
      return
    end

    # put them tracks in them database
    Server.add_new_tracks(server, tracks)

    # the end
    args.unshift "processed"
    server.set_definite_status(*args)
  end


  # check if there is any music added or removed from the server
  # and then add and/or remove from the database
  def self.check_tracks(server)
    args = [:check]
    file_list = server.tracks.map(&:location)

    # get json data from server
    begin
      uri = URI.parse(server.configuration[:location] + "check")
      response = Net::HTTP.post_form(uri, { file_list: file_list.to_json })
    rescue
      args.unshift "processed"
      server.set_definite_status(*args)

      return false
    end

    # parse json
    parsed_response = JSON.parse(response.body)
    missing_files = parsed_response["missing_files"]
    new_tracks = parsed_response["new_tracks"]

    # missing files
    Server.remove_tracks(server, missing_files)

    # new_tracks
    Server.add_new_tracks(server, new_tracks)

    # last checked
    time = Time.now.strftime("%d %b %y / %I:%M %p")

    # the end
    args.unshift "last updated at #{time}"
    server.set_definite_status(*args)
  end
end
