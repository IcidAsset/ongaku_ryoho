require "test_helper"

describe Favourite do
  subject { Favourite.new }

  it { must belong_to(:user) }

  it { must allow_mass_assignment_of(:track_artist) }
  it { must allow_mass_assignment_of(:track_title) }

  it { must validate_presence_of(:track_artist) }
  it { must validate_presence_of(:track_title) }
end