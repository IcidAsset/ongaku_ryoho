class Track < ActiveRecord::Base
  attr_accessible :artist, :title, :album, :genre, :tracknr, :year,
                  :filename, :location, :url

  attr_accessor :available

  #
  #  Associations
  #
  belongs_to :source

  has_one :favourite, dependent: :nullify

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
  validates_presence_of :url

  #
  #  Accessors
  #
  def available
    @available.nil? ? true : @available
  end

  #
  #  Other
  #
  def self.get_unique_first_level_directories(user)
    tracks = self
      .select("DISTINCT ON (left(location, strpos(location, '/'))) tracks.*")
      .where("source_id IN (?) AND location ~* ?", Source.available_ids_for_user(user), "/+")

    tracks.map do |track|
      track.location[/([^\/]*)/]
    end
  end

end
