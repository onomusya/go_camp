FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 } # 例: +819012345678
    postal_code { Faker::Address.postcode }         # 例: "123-4567"
    address { Faker::Address.full_address }         # 例: "東京都新宿区西新宿2-8-1"
  end
end