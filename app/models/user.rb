class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :settings, :remember_me
  serialize :settings, ActiveRecord::Coders::Hstore


  #
  #  Associations
  #
  has_many :sources
  has_many :servers

  has_many :favourites
  has_many :playlists


  #
  #  JSON
  #
  def as_json(options={})
    options = { only: [:settings] }
    super(options)
  end

end
