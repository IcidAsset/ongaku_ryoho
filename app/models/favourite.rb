class Favourite < ActiveRecord::Base
  attr_accessible :artist, :title, :album
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

  #
  #  Clean up user's favourites
  #
  def self.clean_up_user_favourites(user_id)
    favourites = self.where(user_id: user_id)
    source_ids = Source.where(user_id: user_id).pluck(:id).map(&:to_s)

    # loop
    favourites.each do |favourite|
      o = favourite.track_ids
      t = o.clone

      (t.keys - source_ids).each do |old_source_id|
        t.delete(old_source_id)
      end

      if o.keys.length != t.keys.length
        favorite.track_ids = t
        favorite.save
      end
    end
  end

end
