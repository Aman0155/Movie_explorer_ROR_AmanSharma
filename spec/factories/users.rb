FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    mobile_number { Faker::PhoneNumber.unique.cell_phone_in_e164 }
    password { 'Password123!' }
    role { :user }
    notifications_enabled { true }

    trait :supervisor do
      role { :supervisor }
    end

    after(:create) do |user|
      create(:subscription, user: user) unless user.subscription
    end
  end
end