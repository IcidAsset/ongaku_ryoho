ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include Sorcery::TestHelpers::Rails
end



#
#  Turn config
#
Turn.config do |c|
  c.format = :dot
end



#
#  Mongoid Matchers
#
class MiniTest::Spec
  include Mongoid::Matchers
end
