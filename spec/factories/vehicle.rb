FactoryBot.define do
  factory :vehicle do
    customer
    vin { Faker::Vehicle.vin }
    make { Faker::Vehicle.make }
    model { Faker::Vehicle.model }
    color { Faker::Vehicle.color }
  end
end