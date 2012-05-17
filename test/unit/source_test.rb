require 'test_helper'

describe Source do
  subject { Source }
  
  it { must be_document }
  it { must be_timestamped }
  
  it { must have_field(:activated).of_type(Boolean) }
  it { must have_field(:activated).with_default_value(false) }
  it { must have_field(:status).of_type(String) }
  it { must have_field(:status).with_default_value("unprocessed") }
  
  it { must embed_many(:tracks) }
  it { must embedded_in(:user) }
end
