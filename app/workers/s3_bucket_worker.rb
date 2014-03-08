class S3BucketWorker
  include Sidekiq::Worker

  def perform(user_id, s3_bucket_id, data)
    ActiveRecord::Base.connection_pool.with_connection do
      S3BucketWorker.perform_step_two(user_id, s3_bucket_id, data)
    end
  end


  def self.perform_step_two(user_id, s3_bucket_id, data)
    s3_bucket = S3Bucket.find(s3_bucket_id, conditions: { user_id: user_id })

    if s3_bucket
      begin
        S3BucketWorker.update_tracks(s3_bucket, data)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
        s3_bucket.remove_from_redis_queue
        puts "S3BucketWorker could not be processed!"
      end

    else
      s3_bucket.remove_from_redis_queue
      Rails.logger.info "S3Bucket instance not found!"

    end
  end


  def self.update_tracks(s3_bucket, data)
    parsed_data = Oj.load(data)
    file_list = s3_bucket.file_list
    signature_expire_date = DateTime.now.tomorrow.to_i

    # connect to s3 and get bucket file list
    bucket = s3_bucket.fetch_bucket_object
    bucket_file_list = bucket.objects.map { |o| o.key.to_s }
    bucket_file_list = bucket_file_list.select { |o| o.end_with?(*OngakuRyoho::SUPPORTED_FILE_FORMATS) }

    # new / missing
    missing_files = file_list - bucket_file_list
    new_files = bucket_file_list - file_list

    # new tracks
    new_tracks = new_files.map do |key|
      obj_signed_url = s3_bucket.signed_url(key, signature_expire_date, bucket.host)
      ffprobe_command = Rails.env.development? ? "ffprobe" : "bin/ffprobe"
      ffprobe_results = `#{ffprobe_command} -v quiet -print_format json=compact=1 -show_format "#{obj_signed_url}"`
      ffprobe_results = Oj.load(ffprobe_results)
      tags = ffprobe_results.try(:[], "format").try(:[], "tags")

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

    # remove tracks
    S3Bucket.remove_tracks(s3_bucket, missing_files)

    # add new tracks
    S3Bucket.add_new_tracks(s3_bucket, new_tracks)

    # update some attributes if needed
    if file_list.empty? && (missing_files.present? or new_tracks.present?)
      s3_bucket.activated = true
      s3_bucket.processed = true
      s3_bucket.save
    end

    # bind favourites to tracks
    made_bindings = Favourite.bind_favourites_with_tracks(s3_bucket.user_id)

    # if changes -> save
    if !missing_files.empty? or !new_tracks.empty? or made_bindings
      s3_bucket.updated_at = Time.now
      s3_bucket.save
    end

    # remove from redis queue
    s3_bucket.remove_from_redis_queue()
  end

end
