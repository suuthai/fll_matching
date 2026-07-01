FactoryBot.define do
  factory :lesson do
    association :student, factory: :user, role: :student
    association :instructor, factory: :user, role: :instructor
    starts_at { Time.current.beginning_of_hour + 1.day }
  end
end
