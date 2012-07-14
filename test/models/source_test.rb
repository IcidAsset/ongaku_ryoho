require "test_helper"

describe Source do
  subject { Source.new }
  
  it { must belong_to(:user) }
  it { must have_many(:tracks) }
  
  it { must allow_mass_assignment_of(:activated) }
  it { must allow_mass_assignment_of(:configuration) }
  it { must allow_mass_assignment_of(:status) }
  it { must allow_mass_assignment_of(:name) }
  
  it { must validate_presence_of(:configuration) }
  it { must validate_presence_of(:name) }
end