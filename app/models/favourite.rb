class Favourite < ActiveRecord::Base
  attr_accessible :artist, :title, :album, :genre, :tracknr, :year,
                  :filename, :location, :url, :track_id

  #
  #  Associations
  #
  belongs_to :user
  has_one :track


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
  #  Match favourites
  #  -> bind favourites without track_ids
  #     to a matching track
  #
  def self.match_unbounded(source_ids)
    favourites = self.where(track_id: nil)
    favourites = favourites.map do |favourite|
      track = Track.where({
        source_id: source_ids,
        title: favourite.title,
        artist: favourite.artist,
        album: favourite.album,
        favourite_id: nil
      }).first

      if track
        favourite.track_id = track.id
        favourite.save

        track.favourite_id = favourite.id
        track.save
      end

      track ? favourite : nil
    end.compact

    favourites
  end

end
