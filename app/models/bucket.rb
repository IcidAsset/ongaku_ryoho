class Bucket < Source

  key :access_key_id,       String,   :required => true
  key :secret_access_key,   String,   :required => true
  key :bucket,              String,   :required => true

  alias :label :bucket


  # check if the s3 bucket is available
  # and doesn't return any errors
  def available?
    s3_bucket = Bucket.get_s3_bucket(self)
    return (s3_bucket ? true : false)
  end


  # check if there is any music added or removed from the s3 bucket
  # and then add and/or remove from the database
  def check; end


  def process
    require 'open-uri'

    # set
    bucket = Bucket.find(self.user, self.id.to_s, { return_array: true })

    # processing
    Bucket.set_on_each(bucket, :status, 'processing')

    # get s3 bucket
    s3_bucket = Bucket.get_s3_bucket(self)

    unless s3_bucket
      Bucket.set_on_each(bucket, :status, 'unprocessed / bucket not found')
      return false
    end

    # find json file
    begin
      json_s3_object = s3_bucket.objects.find('ongaku_ryoho.json')
      json_file = json_s3_object.content

    rescue
      Bucket.set_on_each(bucket, :status, 'unprocessed / \'ongaku_ryoho.json\' not found')

      return false
    end

    # parse json
    tracks = JSON.parse(json_file)

    # no music =(
    if tracks.empty?
      Server.set_on_each(server, :status, 'unprocessed / no music found')

      return false
    end

    # put them tracks in them database
    Bucket.add_new_tracks_to_each(bucket, s3_bucket, tracks)
  end

  handle_asynchronously :process


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


  def self.add_new_tracks_to_each(selected_buckets, s3_bucket, new_tracks, options={})
    s3_objects = s3_bucket.objects

    selected_buckets.each do |bucket|
      new_tracks.each do |new_track_tags|
        s3_object = s3_objects.select { |x| x.key == new_track_tags['location'] }.first
        bucket.tracks << Track.new( new_track_tags.merge({ url: s3_object.url }) ) if s3_object
      end

      bucket.status = 'processed'
      bucket.activated = true
      bucket.user.save unless options[:dont_save]
    end
  end


  def self.set_on_each(selected_buckets, attribute, value, options={})
    selected_buckets.each do |bucket|
      bucket[attribute] = value
      bucket.user.save unless options[:dont_save]
    end
  end


  def self.find(user, id, options={})
    bucket = user.sources.select { |source|
      source._type == 'Bucket' and source.id.to_s == id
    }

    return options[:return_array] ? bucket : bucket.try(:first)
  end

end
