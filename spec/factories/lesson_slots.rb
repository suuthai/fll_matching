FactoryBot.define do
  factory :lesson_slot do
    association :instructor, factory: :user, role: :instructor
    hour { 10 }
    language { :thai }
  end
end
