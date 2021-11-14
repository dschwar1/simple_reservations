FactoryBot.define do
  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    address { Faker::Address.full_address }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.cell_phone }
  end
end