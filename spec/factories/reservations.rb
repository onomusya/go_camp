FactoryBot.define do
  factory :reservation do
    association :user
    association :site
    start_date { Date.today + 1 }
    end_date { Date.today + 2 }
  end
end