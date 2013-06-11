class ServerWorker
  include Sidekiq::Worker

  def perform(user_id, server_id, data)
    server = Server.find(server_id, conditions: { user_id: user_id })

    if server
      begin
        ServerWorker.update_tracks(server, data)
      rescue
        server.remove_from_redis_queue
        puts "ServerWorker could not process job!"
      end

    else
      server.remove_from_redis_queue
      puts "Server instance not found!"

    end
  end


  def self.update_tracks(server, data)
    parsed_data = Oj.load(data)

    # data might be one of two things
    if parsed_data.kind_of?(Hash)
      missing_files = parsed_data["missing_files"]
      new_tracks = parsed_data["new_tracks"]
    else
      missing_files = []
      new_tracks = parsed_data
    end

    # remove tracks if needed
    Server.remove_tracks(server, missing_files)

    # put them tracks in them database
    Server.add_new_tracks(server, new_tracks)

    # update some attributes if needed
    if !missing_files.empty? or !new_tracks.empty?
      if parsed_data.kind_of?(Array)
        server.activated = true
        server.processed = true
      end
      server.updated_at = Time.now
      server.save
    end

    # bind favourites to tracks
    Favourite.bind_favourites_with_tracks(server.user_id)

    # remove from redis queue
    server.remove_from_redis_queue()
  end

end
