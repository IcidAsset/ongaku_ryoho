class Source < ActiveRecord::Base
  attr_accessible :activated, :configuration, :status, :name
  attr_accessor :available, :label, :track_amount
  serialize :configuration, ActiveRecord::Coders::Hstore

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


  def busy
    self.busy?
  end


  def busy?
    return self.in_queue?
  end


  def in_queue?
    in_queue = $redis.sismember(:process_source_queue, self.id)
    in_queue = $redis.sismember(:check_source_queue, self.id) unless in_queue
    in_queue
  end


  def add_to_redis_queue(type)
    $redis.sadd("#{type}_source_queue".to_sym, self.id)
  end


  def remove_from_redis_queue(type)
    $redis.srem("#{type}_source_queue".to_sym, self.id)
  end


  def set_definite_status(status, type)
    self.status = status.to_s
    self.save
    self.remove_from_redis_queue(type)
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
