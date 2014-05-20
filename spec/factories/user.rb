FactoryGirl.define do
  factory :user do
    email 'test@email.com'
    password 'pass1234'
    confirmed_at DateTime.now
  end
end
