class Source < ActiveRecord::Base
  attr_accessible :activated, :configuration, :status, :name
  attr_accessor :available, :label, :track_amount
  serialize :configuration
  
  belongs_to :user
  has_many :tracks
  
  validates_presence_of :configuration
  validates_presence_of :name
  
  def available
    self.available?
  end
  
  def track_amount
    self.tracks.count
  end
end
