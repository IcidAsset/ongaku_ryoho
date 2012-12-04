class Source < ActiveRecord::Base
  attr_accessible :activated, :configuration, :status, :name
  attr_accessor :available, :label, :track_amount
  serialize :configuration

  belongs_to :user
  has_many :tracks, dependent: :destroy

  validates_presence_of :configuration
  validates_presence_of :name

  def available
    self.available?
  end

  def track_amount
    self.tracks.count
  end

  def self.available_for_user(user)
    sources = self.where(user_id: user.id, activated: true).all
    sources.select { |source| source.available? }
  end

  def self.available_ids_for_user(user)
    sources = self.available_for_user(user)
    sources.map { |source| source.id }
  end
end
