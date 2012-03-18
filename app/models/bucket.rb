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

    # find music
    music_collection = s3_bucket.objects.select { |obj| obj.key =~ /.*\.(mp3)/ }

    # no music =(
    if music_collection.empty?
      Bucket.set_on_each(bucket, :status, 'unprocessed / no music found')

      return false
    end

    # process music
    tracks = Bucket.process_s3_objects(music_collection)

    # put them tracks in them database
    Bucket.add_new_tracks_to_each(bucket, tracks)
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


  def self.process_s3_objects(music_collection)
    tracks = []

    music_collection.each do |s3_object|
      track = Bucket.process_s3_object(s3_object)
      tracks << track if track
    end

    return tracks
  end


  def self.process_s3_object(s3_object)
    require 'open-uri'
    require 'taglib'

    rpartition = s3_object.key.rpartition('/')
    filename   = rpartition[2]

    # track object
    track = {}

    # create temporary file (downloaded file from s3)
    fname = File.basename($0) << '.' << $$.to_s

    File.open(fname, 'wb') do |f|
      f.print open(s3_object.url).read
    end

    # open file
    file = case File.extname(filename)
    when '.mp3'
      ::TagLib::MPEG::File.new(fname)
    end

    # get tags
    tag = file.id3v2_tag

    # set
    tags = {
      title:    tag.title,
      artist:   tag.artist,
      album:    tag.album,
      year:     tag.year,
      tracknr:  tag.track,
      genre:    tag.genre
    }

    tags.each do |key, value|
      tags[key] = 'Unknown' if value.nil? or (value.respond_to?(:empty) and value.empty?)
    end

    tags.merge!({ filename: filename, location: s3_object.key, url: s3_object.url })

    track = tags.clone

    # delete file
    File.delete(fname)

    # add to collection
    if track.empty?
      return false
    else
      return track
    end
  end


  def self.add_new_tracks_to_each(selected_buckets, new_tracks, options={})
    selected_buckets.each do |bucket|
      new_tracks.each do |new_track_tags|
        track = Track.new(new_track_tags)
        bucket.tracks << track
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
