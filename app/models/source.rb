class Source < ActiveRecord::Base
  attr_accessible :activated, :configuration, :status, :name
  serialize :configuration
  
  belongs_to :user
  has_many :tracks
  
  validates_presence_of :configuration
  validates_presence_of :name
end
