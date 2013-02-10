require "test_helper"

describe Track do
  subject { Track.new }

  # associations
  it { must belong_to(:source) }
  it { must have_one(:favourite).dependent(:nullify) }
  it { must have_and_belong_to_many(:playlists) }

  # mass assignment
  it { must allow_mass_assignment_of(:artist) }
  it { must allow_mass_assignment_of(:title) }
  it { must allow_mass_assignment_of(:album) }
  it { must allow_mass_assignment_of(:genre) }
  it { must allow_mass_assignment_of(:tracknr) }
  it { must allow_mass_assignment_of(:year) }
  it { must allow_mass_assignment_of(:filename) }
  it { must allow_mass_assignment_of(:location) }
  it { must allow_mass_assignment_of(:url) }

  # validations
  it { must validate_presence_of(:artist) }
  it { must validate_presence_of(:title) }
  it { must validate_presence_of(:album) }
  it { must validate_presence_of(:tracknr) }
  it { must validate_presence_of(:filename) }
  it { must validate_presence_of(:location) }
  it { must validate_presence_of(:url) }
end
