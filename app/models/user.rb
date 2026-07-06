class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :lessons_as_student, class_name: "Lesson", foreign_key: :student_id
  has_many :lessons_as_instructor, class_name: "Lesson", foreign_key: :instructor_id, dependent: :destroy

  enum :role, { student: 0, instructor: 1, admin: 2 }

  LANGUAGES = %i[thai vietnamese lao khmer burmese].freeze

  validates :name, presence: true

  def recent_instructor
    lessons_as_student.order(created_at: :desc).first&.instructor
  end

  def instructable_languages
    LANGUAGES.select { |language| self["can_instruct_#{language}"] }
  end
end
