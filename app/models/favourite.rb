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
  def bind_track(source_id, track_id)
    track_ids = self.track_ids

    # get track
    track = Track.find(track_id)

    # check
    return unless track

    # convert to string
    source_id = source_id.to_s
    track_id = track_id.to_s

    # create {{source_id}} key if doesn't exist yet
    unless track_ids[source_id]
      track_ids[source_id] = ""
    end

    # get track ids for this source id
    source_track_ids = track_ids[source_id].split(",")

    # update key -> value
    unless source_track_ids.include?(track_id)
      source_track_ids << track_id
    end

    # array -> string
    track_ids[source_id] = source_track_ids.join(",")

    # set favourite_id on track
    track.favourite_id = self.id

    # save in db
    ActiveRecord::Base.transaction do
      self.save
      track.save
    end
  end


  #
  #  Bind tracks to favourites
  #  -> bind the user's favourites
  #     to all matching tracks
  #
  def self.bind_favourites_with_tracks(user_id)
    favourites = self.where(user_id: user_id)
  end

end
