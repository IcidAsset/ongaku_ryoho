class Favourite < ActiveRecord::Base
  attr_accessible :artist, :title, :album, :genre, :tracknr, :year,
                  :filename, :location, :url

  serialize :track_ids, ActiveRecord::Coders::Hstore

  #
  #  Associations
  #
  belongs_to :user


  #
  #  Validations
  #
  validates_presence_of :artist
  validates_presence_of :title
  validates_presence_of :album
  validates_presence_of :tracknr
  validates_presence_of :filename
  validates_presence_of :location
  validates_presence_of :url


  #
  #  Instance methods
  #
  def bind_track(track)
    track_ids = self.track_ids
    changed = false

    # convert to string
    source_id = track.source_id.to_s
    track_id = track.id.to_s

    # create {{source_id}} key if doesn't exist yet
    unless track_ids[source_id]
      track_ids[source_id] = ""
    end

    # get track ids for this source id
    source_track_ids = track_ids[source_id].split(",")

    # update key -> value
    unless source_track_ids.include?(track_id)
      source_track_ids << track_id

      track_ids[source_id] = source_track_ids.join(",")
      track.favourite_id = self.id

      ActiveRecord::Base.transaction do
        self.save
        track.save
      end

      changed = true
    end

    # return
    changed
  end

  def unbind_track(track)
    track_ids = self.track_ids

    # convert to string
    source_id = track.source_id.to_s
    track_id = track.id.to_s

    # check
    return unless track_ids[source_id]

    # get track ids for this source id
    source_track_ids = track_ids[source_id].split(",")

    # delete track_id
    source_track_ids.delete(track_id)

    # array -> string
    if source_track_ids.empty?
      track_ids.delete(source_id)
    else
      track_ids[source_id] = source_track_ids.join(",")
    end

    # save
    self.save
  end

  def has_unknown_tags?
    return self.artist.downcase == "unknown" && self.title.downcase == "unknown"
  end

  #
  #  Bind tracks to favourites
  #  -> bind the user's favourites
  #     to all matching tracks
  #
  def self.bind_favourites_with_tracks(user_id, favourite=nil)
    favourites = if favourite
      [favourite]
    else
      self.where(user_id: user_id)
    end

    source_ids = Source.where(user_id: user_id, activated: true).pluck(:id)
    changes = false

    # loop
    favourites.each do |favourite|
      next if favourite.has_unknown_tags?

      tracks = Track.where(
        source_id: source_ids,
        artist: favourite.artist,
        title: favourite.title,
        album: favourite.album
      )

      tracks.each do |track|
        changed = favourite.bind_track(track)
        changes = changed unless changes
      end
    end

    # return
    changes
  end

end
