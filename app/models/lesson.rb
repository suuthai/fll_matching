class Lesson < ApplicationRecord
  belongs_to :student, class_name: "User"
  belongs_to :instructor, class_name: "User"
  validates :starts_at, presence: true
end
