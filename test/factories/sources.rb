FactoryGirl.define do

  # base
  factory :source do; end
  
  # server
  factory :server do
    name 'test'
    location 'localhost:4567'
  end

end