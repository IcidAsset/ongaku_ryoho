class S3BucketJob
  include SuckerPunch::Job

  def perform(user_id, s3_bucket_id, data)
    ActiveRecord::Base.connection_pool.with_connection do
      S3BucketJob.perform_step_two(user_id, s3_bucket_id, data)
    end
  end


  def self.perform_step_two(user_id, s3_bucket_id, data)
    s3_bucket = S3Bucket.find(s3_bucket_id, conditions: { user_id: user_id })

    if s3_bucket
      begin
        S3BucketJob.update_tracks(s3_bucket, data)
      rescue
        s3_bucket.remove_from_redis_queue
        puts "S3BucketJob could not be processed!"
      end

    else
      s3_bucket.remove_from_redis_queue
      Rails.logger.info "S3Bucket instance not found!"

    end
  end


  def self.update_tracks(s3_bucket, data)
    parsed_data = Oj.load(data)
    file_list = s3_bucket.file_list

    # connect to s3 and get bucket file list
    service = S3::Service.new(access_key_id: s3_bucket.configuration["access_key"],
                              secret_access_key: s3_bucket.configuration["secret_key"])

    bucket = service.buckets.find(s3_bucket.configuration["bucket"])
    bucket_file_list = bucket.objects.map { |o| o.key.to_s }
    bucket_file_list = bucket_file_list.select { |o| o.end_with?(*OngakuRyoho::SUPPORTED_FILE_FORMATS) }

    # new / missing
    missing_files = file_list - bucket_file_list
    new_files = bucket_file_list - file_list

    # new tracks
    new_tracks = new_files.map do |key|
      obj = bucket.objects.find(key)
      ffprobe_command = Rails.env.development? ? "ffprobe" : "bin/ffprobe"
      ffprobe_results = `#{ffprobe_command} -v quiet -print_format json=compact=1 -show_format '#{obj.url}'`
      ffprobe_results = Oj.load(ffprobe_results)
      tags = ffprobe_results["format"]["tags"]

      {
        title: tags["title"],
        artist: tags["artist"],
        album: tags["album"],
        year: tags["date"] || tags["year"],
        tracknr: tags["track"].split("/").first,
        genre: tags["genre"],

        filename: key.split("/").last,
        location: key,
        url: obj.url
      }
    end

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
