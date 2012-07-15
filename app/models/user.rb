class User < ActiveRecord::Base
  attr_accessible :email, :password
  
  authenticates_with_sorcery!
  
  has_many :sources
  has_many :servers
  
  has_many :favourites
  
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email,
    :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/,
    :on => :create,
    :messsage => "is invalid"
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
end
