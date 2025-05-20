FactoryBot.define do
  factory :reservation_item do
    association :reservation
    association :item
  end
end