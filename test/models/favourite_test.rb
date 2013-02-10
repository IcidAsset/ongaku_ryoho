require "test_helper"

describe Favourite do
  subject { Favourite.new }

  # associations
  it { must belong_to(:user) }
  it { must have_one(:track) }

  # mass assignment
  it { must allow_mass_assignment_of(:artist) }
  it { must allow_mass_assignment_of(:title) }
  it { must allow_mass_assignment_of(:album) }
  it { must allow_mass_assignment_of(:track_id) }

  # validations
  it { must validate_presence_of(:artist) }
  it { must validate_presence_of(:title) }
  it { must validate_presence_of(:album) }
end
