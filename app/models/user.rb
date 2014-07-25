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
  has_many :sources, dependent: :destroy

  has_many :favourites, dependent: :destroy
  has_many :playlists, dependent: :destroy


  #
  #  JSON
  #
  def as_json(options={})
    options = { only: [:settings] }
    super(options)
  end

end
