class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :lessons_as_student, class_name: "Lesson", foreign_key: :student_id
  has_many :lessons_as_instructor, class_name: "Lesson", foreign_key: :instructor_id

  enum :role, { student: 0, instructor: 1, admin: 2 }

  enum :instructional_language, {
    thai: 0,
    vietnamese: 1,
    lao: 2,
    khmer: 3,
    burmese: 4
  }
  
end
