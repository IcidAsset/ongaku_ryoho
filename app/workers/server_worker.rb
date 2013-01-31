class ServerWorker
  include Sidekiq::Worker

  def perform(user_id, server_id, method_name)
    server = Server.find(server_id, conditions: { user_id: user_id })
    ServerWorker.send(method_name.to_sym, server) if server
  end

  # check if there is any music added or removed from the server
  # and then add and/or remove from the database
  def self.check_tracks(server)
    require "net/http"

    # check
    return false if server.busy?

    # processing
    server.status = "processing"
    server.save

    # make file list
    file_list = server.tracks.map(&:location)

    # get json data from server
    begin
      uri = URI.parse(self.configuration[:location] + "check")
      response = Net::HTTP.post_form(uri, { file_list: file_list.to_json })
    rescue
      server.status = "processed"
      server.save

      return false
    end

    # parse json
    parsed_reponse = JSON.parse(response.body)
    missing_files = parsed_reponse["missing_files"]
    new_tracks = parsed_reponse["new_tracks"]

    # missing files
    Server.remove_tracks(server, missing_files)

    # new_tracks
    Server.add_new_tracks(server, new_tracks)

    # last checked
    time = Time.now.strftime("%d %b %y / %I:%M %p")
    server.status = "last updated at #{time}"

    # the end
    server.save
  end


  def self.process_tracks(server)
    require "net/http"

    # check
    return false if server.busy?

    # processing
    server.status = "processing"
    server.save

    # get json data from server
    begin
      uri = URI.parse(self.configuration[:location])
      response = Net::HTTP.get(uri)
    rescue
      server.status = "unprocessed / server not found"
      server.save

      return
    end

    # parse json
    tracks = JSON.parse(reponse)

    # no music =(
    if tracks.empty?
      server.status = "unprocessed / no music found"
      server.save

      return
    end

    # put them tracks in them database
    Server.add_new_tracks(server, tracks)

    # the end
    server.status = "processed"
    server.save
  end
end
