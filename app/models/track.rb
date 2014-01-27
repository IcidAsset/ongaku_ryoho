class Track < ActiveRecord::Base
  attr_accessible :artist, :title, :album, :genre, :tracknr, :year,
                  :filename, :location, :url

  attr_accessor :available

  #
  #  Associations
  #
  belongs_to :source
  belongs_to :favourite

  has_many :playlists_tracks
  has_many :playlists, through: :playlists_tracks


  #
  #  Validations
  #
  validates_presence_of :artist
  validates_presence_of :title
  validates_presence_of :album
  validates_presence_of :tracknr
  validates_presence_of :filename
  validates_presence_of :location


  #
  #  Accessors
  #
  def available
    @available.nil? ? true : @available
  end


  #
  #  Get unique first level directories
  #
  def self.get_unique_first_level_directories(source_ids)
    tracks = self
      .select("DISTINCT ON (left(location, strpos(location, '/'))) tracks.*")
      .where("source_id IN (?) AND location ~* ?", source_ids, "/+")

    tracks.map do |track|
      track.location[/([^\/]*)/]
    end
  end

private

  def remove_track_id_from_favourite
    self.favourite.unbind_track(self) if self.favourite
  end

end
