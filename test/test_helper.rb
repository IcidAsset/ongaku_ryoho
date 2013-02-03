ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

require "minitest/autorun"
require "minitest/spec"
require "minitest/rails"

require "shoulda/matchers/action_controller"
require "shoulda/matchers/action_mailer"
require "shoulda/matchers/active_record"
require "shoulda/matchers/active_model"

MiniTest::Rails.override_testunit!



#
#  Extend MiniTest
#
class MiniTest::Rails::ActiveSupport::TestCase
  include Shoulda::Matchers::ActionMailer
  extend Shoulda::Matchers::ActionMailer
  include Shoulda::Matchers::ActiveRecord
  extend Shoulda::Matchers::ActiveRecord
  include Shoulda::Matchers::ActiveModel
  extend Shoulda::Matchers::ActiveModel

  include Sorcery::TestHelpers::Rails
end

class MiniTest::Rails::ActionController::TestCase
  include Shoulda::Matchers::ActionController
  extend Shoulda::Matchers::ActionController

  def subject
    @controller
  end
end



#
#  MiniTest Expansion Pack
#
module MiniTest
  module Assertions
    def assert_must(subject, matcher, msg = nil)
      msg = message(msg) do
        if matcher.respond_to? :failure_message
          "Expected #{matcher.failure_message}".squeeze(" ")
        else
          "Expected #{subject.inspect} to #{matcher.description}".squeeze(" ")
        end
      end

      assert matcher.matches?(subject), msg
    end

    def assert_wont(subject, matcher, msg = nil)
      msg = message(msg) do
        if matcher.respond_to? :negative_failure_message
          "Expected #{matcher.negative_failure_message}".squeeze(" ")
        else
          "Expected not to #{matcher.description}".squeeze(" ")
        end
      end

      refute matcher.matches?(subject), msg
    end
  end

  module Expectations
    infect_an_assertion :assert_must, :must, :reverse
    infect_an_assertion :assert_wont, :wont, :reverse
  end
end

class MiniTest::Spec
  def must(*args, &block)
    subject.must(*args, &block)
  end

  def wont(*args, &block)
    subject.wont(*args, &block)
  end
end



#
#  Turn config
#
Turn.config do |c|
  c.format = :dot
end
