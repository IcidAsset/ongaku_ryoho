class ServerWorker
  include Sidekiq::Worker

  def perform(user_id, server_id, data)
    ActiveRecord::Base.connection_pool.with_connection do
      perform_step_two(user_id, server_id, data)
    end
  end


  def perform_step_two(user_id, server_id, data)
    server = Server.find(server_id, conditions: { user_id: user_id })
    @log_prefix = "[u#{user_id}/s#{server.try(:id) || '?'}]"

    if server
      begin
        update_tracks(server, data, user_id)
      rescue => e
        logger.info { e.message }
        logger.info { e.backtrace.inspect }
        server.remove_from_redis_queue
        logger.info { "ServerWorker could not be processed!" }
      end

    else
      server.remove_from_redis_queue
      logger.info { "Server instance not found!" }

    end
  end


  def update_tracks(server, data, user_id)
    parsed_data = Oj.load(data)
    batch_counter = 0

    # data might be one of two things
    if parsed_data.kind_of?(Hash)
      missing_files = parsed_data["missing_files"]
      new_tracks = parsed_data["new_tracks"]
    else
      missing_files = []
      new_tracks = parsed_data
    end

    logger.info { "#{@log_prefix} removed: #{missing_files.size}" }
    logger.info { "#{@log_prefix} added: #{new_tracks.size}" }

    # remove tracks if needed
    Server.remove_tracks(server, missing_files)

    # put them tracks in them database
    new_tracks.each_slice(25) do |batch|
      Server.add_new_tracks(server, batch)
      batch_counter = batch_counter + 1

      logger.info { "#{@log_prefix} batch *#{batch_counter}* added: #{batch.size} tracks" }
    end

    # update some attributes if needed
    if parsed_data.kind_of?(Array) && (missing_files.present? or new_tracks.present?)
      server.activated = true
      server.processed = true
      server.save
    end

    # bind favourites to tracks
    made_bindings = Favourite.bind_favourites_with_tracks(server.user_id)

    # if changes -> save
    if missing_files.present? or new_tracks.present? or made_bindings
      server.updated_at = Time.now
      server.save
    end

    # remove from redis queue
    server.remove_from_redis_queue()
  end

end
