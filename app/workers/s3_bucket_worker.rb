class S3BucketWorker
  include Sidekiq::Worker

  def perform(user_id, s3_bucket_id, data)
    ActiveRecord::Base.connection_pool.with_connection do
      perform_step_two(user_id, s3_bucket_id, data)
    end
  end


  def perform_step_two(user_id, s3_bucket_id, data)
    s3_bucket = S3Bucket.find(s3_bucket_id, conditions: { user_id: user_id })
    @log_prefix = "[u#{user_id}/s#{s3_bucket.try(:id) || '?'}]"

    if s3_bucket
      begin
        update_tracks(s3_bucket, data, user_id)
      rescue => e
        logger.info { e.message }
        logger.info { e.backtrace.inspect }
        s3_bucket.remove_from_redis_queue
        logger.info { "#{@log_prefix} S3BucketWorker could not be processed!" }
      end

    else
      s3_bucket.remove_from_redis_queue
      logger.info { "#{@log_prefix} S3Bucket instance not found!" }

    end
  end


  def update_tracks(s3_bucket, data, user_id)
    parsed_data = Oj.load(data)
    file_list = s3_bucket.file_list
    signature_expire_date = DateTime.now.tomorrow.to_i
    new_tracks_counter = 0
    batch_counter = 0

    # connect to s3 and get bucket file list
    bucket = s3_bucket.fetch_bucket_object
    bucket_file_list = bucket.objects.map { |o| o.key.to_s }
    bucket_file_list = bucket_file_list.select { |o| o.end_with?(*OngakuRyoho::SUPPORTED_FILE_FORMATS) }

    # new / missing
    missing_files = file_list - bucket_file_list
    new_files = bucket_file_list - file_list

    logger.info { "#{@log_prefix} removed: #{missing_files.size}" }
    logger.info { "#{@log_prefix} added: #{new_files.size}" }

    # remove tracks
    S3Bucket.remove_tracks(s3_bucket, missing_files)

    # add new tracks
    new_files.each_slice(25) do |batch|
      new_tracks = process_keys_array(s3_bucket, bucket, signature_expire_date, batch)
      new_tracks_counter = new_tracks_counter + new_tracks.size
      batch_counter = batch_counter + 1

      S3Bucket.add_new_tracks(s3_bucket, new_tracks)

      logger.info { "#{@log_prefix} batch *#{batch_counter}* added: #{batch.size} tracks" }
    end

    # update some attributes if needed
    if file_list.empty? && (missing_files.size > 0 or new_tracks_counter > 0)
      s3_bucket.activated = true
      s3_bucket.processed = true
      s3_bucket.save
    end

    # bind favourites to tracks
    made_bindings = Favourite.bind_favourites_with_tracks(s3_bucket.user_id)

    # if changes -> save
    if missing_files.size > 0 or new_tracks_counter > 0 or made_bindings
      s3_bucket.updated_at = Time.now
      s3_bucket.save
    end

    # remove from redis queue
    s3_bucket.remove_from_redis_queue()
  end


  def process_keys_array(s3_bucket, bucket, signature_expire_date, array)
    array.map do |key|
      obj_signed_url = s3_bucket.signed_url(key, signature_expire_date, bucket.host)
      ffprobe_command = Rails.env.development? ? "ffprobe" : "bin/ffprobe"
      ffprobe_results = `#{ffprobe_command} -v quiet -print_format json=compact=1 -show_format "#{obj_signed_url}"`
      ffprobe_results = Oj.load(ffprobe_results)
      tags = ffprobe_results.try(:[], "format").try(:[], "tags")

      logger.info { "#{@log_prefix} processed: #{key}" }

      if tags
        {
          title: tags["title"],
          artist: tags["artist"],
          album: tags["album"],
          year: tags["date"] || tags["year"],
          tracknr: tags["track"].try(:split, "/").try(:first) || 0,
          genre: tags["genre"],

          filename: key.split("/").last,
          location: key
        }
      end
    end.compact
  end

end
