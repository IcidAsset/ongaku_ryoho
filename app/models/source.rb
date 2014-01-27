class Source < ActiveRecord::Base
  attr_accessible :id, :activated, :processed, :name, :configuration
  attr_accessor :track_amount
  serialize :configuration, ActiveRecord::Coders::Hstore

  #
  #  Associations
  #
  belongs_to :user
  has_many :tracks


  #
  #  Callbacks
  #
  before_destroy :remove_related_items


  #
  #  Validations
  #
  validates_presence_of :configuration
  validates_presence_of :name
  validates_presence_of :user_id


  #
  #  Instance methods
  #
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


  def update_with_selected_attributes(attributes_from_client)
    attrs = attributes_from_client.select do |k, v|
      %w(name configuration activated).include?(k.to_s)
    end

    self.update_attributes(attrs)
  end


  def remove_related_items
    Tracks.where(source_id: self.id).delete_all
    Favourite.clean_up_user_favourites(self.user_id)
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
