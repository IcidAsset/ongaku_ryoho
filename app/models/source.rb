class Source < ActiveRecord::Base
  attr_accessible :id, :activated, :processed, :name, :configuration
  attr_accessor :track_amount
  serialize :configuration, ActiveRecord::Coders::Hstore

  #
  #  Associations
  #
  belongs_to :user
  has_many :tracks


  #
  #  Callbacks
  #
  before_destroy :remove_related_items


  #
  #  Validations
  #
  validates_presence_of :configuration
  validates_presence_of :name
  validates_presence_of :user_id


  #
  #  Instance methods
  #
  def track_amount
    self.tracks.count
  end


  def file_list
    self.tracks.pluck(:location)
  end


  def busy
    self.busy?
  end


  def busy?
    return self.in_queue?
  end


  def in_queue?
    $redis.sismember(:source_queue, self.id)
  end


  def update_with_selected_attributes(attributes_from_client)
    attrs = attributes_from_client.select do |k, v|
      %w(name configuration activated).include?(k.to_s)
    end

    self.update_attributes(attrs)
  end


  def remove_related_items
    Track.where(source_id: self.id).delete_all
    Favourite.clean_up_user_favourites(self.user_id)
    PlaylistsTrack.where(track_id: self.id).delete_all
  end


  #
  #  Redis helpers
  #
  def add_to_redis_queue
    $redis.sadd(:source_queue, self.id)
  end


  def remove_from_redis_queue
    $redis.srem(:source_queue, self.id)
  end


  #
  #  Utility functions
  #
  def self.parse_track_tag_value(value)
    new_value = if !value
      "Unknown"
    elsif value.is_a?(String)
      (value.length > 255 ? value[0...255] : value).scrub
    else
      value
    end

    new_value
  end


  def self.probe_audio_file(options={})
    # ffprobe_command = Rails.env.development? ? "ffprobe" : "bin/ffprobe"
    ffprobe_command = "ffprobe"
    ffprobe_results = if options[:url]
      url = options[:url]
      `#{ffprobe_command} -v quiet -show_format "#{url}"`
    else
      "" # fallback
    end

    tags = ffprobe_results.split("\n")
    tags = tags.select { |l| l.start_with?("TAG:") }
    tags = tags.map { |l| l.sub("TAG:", "").split("=") }

    if tags.length
      tags = Hash[*tags.flatten]

      if tags["title"] && tags["artist"]
        {
          title: tags["title"],
          artist: tags["artist"],
          album: tags["album"] || "Unknown",
          year: tags["date"] || tags["year"] || "Unknown",
          tracknr: tags["track"].try(:split, "/").try(:first) || 0,
          genre: tags["genre"] || "Unknown",

          filename: options[:file_path].split("/").last,
          location: options[:file_path]
        }
      end
    end
  end


  def self.probe_audio_file_via_url(url, file_path)
    Source.probe_audio_file(url: url, file_path: file_path)
  end

end
