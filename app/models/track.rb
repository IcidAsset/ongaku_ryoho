class Track < ActiveRecord::Base
  attr_accessible :artist, :title, :album, :genre, :tracknr, :year,
                  :filename, :location, :url

  attr_accessor :available

  belongs_to :source
  has_one :favourite, dependent: :nullify
  has_and_belongs_to_many :playlists

  validates_presence_of :artist
  validates_presence_of :title
  validates_presence_of :album
  validates_presence_of :tracknr
  validates_presence_of :filename
  validates_presence_of :location
  validates_presence_of :url

  #
  # Accessors
  #
  def available
    @available.nil? ? true : @available
  end

end
