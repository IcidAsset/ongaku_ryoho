class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  attr_accessible :email, :password, :password_confirmation, :settings
  serialize :settings, ActiveRecord::Coders::Hstore


  #
  #  Associations
  #
  has_many :sources
  has_many :servers

  has_many :favourites
  has_many :playlists


  #
  #  Validations
  #
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email,
    :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/,
    :on => :create,
    :messsage => "is invalid"

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create


  #
  #  JSON
  #
  def as_json(options={})
    options = { only: [:settings] }
    super(options)
  end

end
