FactoryBot.define do
  factory :reservation do
    vehicle
    start_time { Faker::Time.between(from: DateTime.now, to: DateTime.now + 3.days) }
    end_time { Faker::Time.between(from: DateTime.now + 3.days, to: DateTime.now + 7.days) }
  end
end