require "test_helper"

describe Playlist do
  subject { Playlist.new }

  # associations
  it { must belong_to(:user) }
  it { must have_and_belong_to_many(:tracks) }

  # mass assignment & validations
  it { must allow_mass_assignment_of(:name) }
  it { must validate_presence_of(:name) }

  # accessors
  it "must have an accessor :special" do
    subject.must_respond_to :special=
  end
end
