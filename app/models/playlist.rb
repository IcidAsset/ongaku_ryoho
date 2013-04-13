class Playlist < ActiveRecord::Base
  attr_accessible :name
  attr_accessor :special

  belongs_to :user
  has_and_belongs_to_many :tracks
  accepts_nested_attributes_for :tracks

  validates_presence_of :name
end
