class DropboxWorker
  include Sidekiq::Worker

  def perform(user_id, dropbox_id, data)
    ActiveRecord::Base.connection_pool.with_connection do
      perform_step_two(user_id, dropbox_id, data)
    end
  end


  def perform_step_two(user_id, dropbox_id, data)
    dropbox = DropboxAccount.find(dropbox_id, conditions: { user_id: user_id })
    @log_prefix = "[u#{user_id}/s#{dropbox.try(:id) || '?'}]"

    if dropbox
      begin
        update_tracks(dropbox, data, user_id)
      rescue => e
        logger.info { e.message }
        logger.info { e.backtrace.inspect }
        dropbox.remove_from_redis_queue
        logger.info { "#{@log_prefix} DropboxWorker could not be processed!" }
      end

    else
      dropbox.remove_from_redis_queue
      logger.info { "#{@log_prefix} Dropbox instance not found!" }

    end
  end


  def update_tracks(dropbox, data, user_id)
    directory = dropbox.configuration["directory"]
    access_token = dropbox.configuration["access_token"]
    dropbox_client = DropboxClient.new(access_token)
    current_file_list = dropbox.file_list
    new_tracks_counter = 0
    batch_counter = 0

    # directory
    directory = directory.strip.chomp("/")
    directory = directory.sub(/^\/+/, "")

    # dropbox file list
    dropbox_file_list = make_dropbox_file_list(
      dropbox_client,
      directory
    )

    # new / missing
    missing_files = current_file_list - dropbox_file_list
    new_files = dropbox_file_list - current_file_list

    logger.info { "#{@log_prefix} removed: #{missing_files.size}" }
    logger.info { "#{@log_prefix} added: #{new_files.size}" }

    # remove tracks
    DropboxAccount.remove_tracks(dropbox, missing_files)

    # add new tracks
    new_files.each_slice(25) do |batch|
      new_tracks = process_batch(dropbox, dropbox_client, batch, directory)
      new_tracks_counter = new_tracks_counter + new_tracks.size
      batch_counter = batch_counter + 1

      DropboxAccount.add_new_tracks(dropbox, new_tracks)

      logger.info { "#{@log_prefix} batch *#{batch_counter}* added: #{new_tracks.size} (#{batch.size}) tracks" }
    end

    # update some attributes if needed
    if (current_file_list.empty? && (missing_files.size > 0 || new_tracks_counter > 0)) ||
       (!current_file_list.empty? && !dropbox.processed)
      dropbox.activated = true
      dropbox.processed = true
      dropbox.save
    end

    # bind favourites to tracks
    made_bindings = Favourite.bind_favourites_with_tracks(dropbox.user_id)

    # if changes -> save
    if missing_files.size > 0 || new_tracks_counter > 0 || made_bindings
      dropbox.updated_at = Time.now
      dropbox.save
    end

    # remove from redis queue
    dropbox.remove_from_redis_queue()
  end


  def make_dropbox_file_list(dropbox_client, directory)
    contents = []

    OngakuRyoho::SUPPORTED_FILE_FORMATS.each do |format|
      # extension === format
      contents.push dropbox_client.search("/#{directory}", ".#{format}")
    end

    file_list = contents.flatten.map do |obj|
      unless obj["is_dir"]
        obj["path"].sub(/^\/*#{directory}\/*/i, "")
      end
    end.compact

    file_list = file_list.flatten.select do |path|
      path.end_with?(*OngakuRyoho::SUPPORTED_FILE_FORMATS)
    end

    file_list
  end


  def process_batch(dropbox, dropbox_client, batch, directory)
    batch.map do |path|
      media_response = dropbox_client.media("/#{directory}/#{path}")
      media_url = media_response["url"]
      tags = Source.probe_audio_file_via_url(media_url, path)

      logger.info { "#{@log_prefix} processed: #{path}" }

      tags
    end.compact
  end

end
