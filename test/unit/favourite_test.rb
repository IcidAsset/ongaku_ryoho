require 'test_helper'

describe Favourite do
  subject { Favourite }

  it { must be_document }
  it { must be_timestamped }

  it { must have_field(:track_title).of_type(String) }
  it { must have_field(:track_artist).of_type(String) }

  it { must embedded_in(:user) }
end
