class S3Bucket < Source

  #
  #  Worker
  #
  def self.worker
    S3BucketWorker
  end


  #
  #  Signature
  #
  def signed_url(key, expire_date, host)
    source = self
    bucket = source.configuration['bucket']
    path = URI.escape(key.strip)

    digest = OpenSSL::Digest.new("sha1")
    can_string = "GET\n\n\n#{expire_date}\n/#{bucket}/#{path}"
    hmac = OpenSSL::HMAC.digest(digest, source.configuration['secret_key'], can_string)
    signature = URI.escape(Base64.encode64(hmac).strip, "+=?@$&,/:;")

    query_string = "?AWSAccessKeyId=#{source.configuration['access_key']}"
    query_string << "&Expires=#{expire_date}&Signature=#{signature}"

    url = "http://#{host}/#{path}"
    signed_url = url + query_string

    signed_url
  end


  #
  #  Override ActiveRecord::Base.new
  #
  def self.new(attributes=nil, options={}, user_id, ip_address)
    s3_bucket = super(attributes, options)
    s3_bucket.user_id = user_id
    s3_bucket
  end


  #
  #  Override as_json
  #
  def as_json(options={})
    json = super(options)
    json["s3_host"] = self.fetch_bucket_object.try(:host)
    json["configuration"].delete("secret_key")

    json
  end


  #
  #  Utility functions
  #
  def fetch_bucket_object
    service = S3::Service.new(access_key_id: self.configuration["access_key"],
                              secret_access_key: self.configuration["secret_key"])

    return service.buckets.find(self.configuration["bucket"])
  end


  def self.add_new_tracks(s3_bucket, new_tracks)
    return unless new_tracks.present?

    # attributes -> models
    new_track_models = new_tracks.map do |tags|
      tags.each do |tag, value|
        tags[tag] = Source.parse_track_tag_value(value)
      end

      new_track_model = Track.new(tags)
      new_track_model.source_id = s3_bucket.id

      new_track_model
    end

    # save models
    ActiveRecord::Base.transaction do
      new_track_models.each(&:save)
    end
  end


  def self.remove_tracks(s3_bucket, missing_files)
    return unless missing_files.present?

    # collect tracks
    tracks = Track.where(location: missing_files, source_id: s3_bucket.id)

    # destroy tracks
    tracks.destroy_all
  end

end
