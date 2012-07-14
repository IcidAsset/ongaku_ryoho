class Track < ActiveRecord::Base
  attr_accessible :artist, :title, :album, :genre, :tracknr, :year, :filename, :location, :url
  belongs_to :source
  
  validates_presence_of :artist
  validates_presence_of :title
  validates_presence_of :album
  validates_presence_of :tracknr
  validates_presence_of :filename
  validates_presence_of :location
  validates_presence_of :url
end