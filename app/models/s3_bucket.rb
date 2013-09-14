class S3Bucket < Source

  #
  #  Worker
  #
  def self.worker
    S3BucketJob
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
  #  Utility functions
  #
  def self.add_new_tracks(s3_bucket, new_tracks)
    return unless new_tracks.present?

    # attributes -> models
    new_track_models = new_tracks.map do |tags|
      tags.each do |tag, value|
        if !value
          tags[tag] = "Unknown"
        elsif value.is_a?(String) and value.length > 255
          tags[tag] = value[0...255]
        end
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
