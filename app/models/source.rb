class Source < ActiveRecord::Base
  attr_accessible :id, :activated, :processed, :name, :configuration
  attr_accessor :available, :label, :track_amount
  serialize :configuration, ActiveRecord::Coders::Hstore

  #
  #  Associations
  #
  belongs_to :user
  has_many :tracks, dependent: :destroy


  #
  #  Validations
  #
  validates_presence_of :configuration
  validates_presence_of :name


  #
  #  Class methods
  #
  def self.available_for_user(user)
    sources = self.where(user_id: user.id, activated: true).all
    sources.select { |source| source.available? }
  end


  def self.available_ids_for_user(user)
    sources = self.available_for_user(user)
    sources.map { |source| source.id }
  end


  #
  #  Instance methods
  #
  def available
    self.available?
  end


  def track_amount
    self.tracks.count
  end


  def file_list
    self.tracks.pluck(:location)
  end


  def busy
    self.busy?
  end


  def busy?
    return self.in_queue?
  end


  def in_queue?
    $redis.sismember(:source_queue, self.id)
  end


  #
  #  Redis helpers
  #
  def add_to_redis_queue
    $redis.sadd(:source_queue, self.id)
  end


  def remove_from_redis_queue
    $redis.srem(:source_queue, self.id)
  end

end
