class Bucket < Source

  field :access_key_id,       type: String,   required: true
  field :secret_access_key,   type: String,   required: true
  field :bucket,              type: String,   required: true

  alias :label :bucket


  # check if the s3 bucket is available
  # and doesn't return any errors
  def available?
    s3_bucket = Bucket.get_s3_bucket(self)
    return (s3_bucket ? true : false)
  end


  # check if there is any music added or removed from the s3 bucket
  # and then add and/or remove from the database
  def check_tracks
    return false
  end


  def process_tracks
    require 'open-uri'

    # processing
    self.status = 'processing'

    # get s3 bucket
    s3_bucket = Bucket.get_s3_bucket(self)

    unless s3_bucket
      self.status = 'unprocessed / bucket not found'
      self.save
      
      return false
    end

    # find json file
    begin
      json_s3_object = s3_bucket.objects.find('ongaku_ryoho.json')
      json_file = json_s3_object.content

    rescue
      self.status = 'unprocessed / \'ongaku_ryoho.json\' not found'
      self.save

      return false
    end

    # parse json
    tracks = JSON.parse(json_file)

    # no music =(
    if tracks.empty?
      self.status = 'unprocessed / no music found'
      self.save

      return false
    end

    # put them tracks in them database
    Bucket.add_new_tracks(self, s3_bucket, tracks)
    
    # the end
    self.save
  end


  def self.get_s3_bucket(bucket)
    service = S3::Service.new(
      :access_key_id => bucket.access_key_id,
      :secret_access_key => bucket.secret_access_key
    )

    begin
      return service.buckets.find(bucket.bucket)
    rescue
      return false
    end
  end


  def self.add_new_tracks(bucket, s3_bucket, new_tracks)
    s3_objects = s3_bucket.objects

    new_tracks.each do |new_track_tags|
      s3_object = s3_objects.select { |x| x.key == new_track_tags['location'] }.first
      bucket.tracks.build( new_track_tags.merge({ url: s3_object.url }) ) if s3_object
    end

    bucket.status = 'processed'
    bucket.activated = true
  end

end
