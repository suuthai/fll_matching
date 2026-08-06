class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :lessons_as_student, class_name: "Lesson", foreign_key: :student_id
  has_many :lessons_as_instructor, class_name: "Lesson", foreign_key: :instructor_id, dependent: :destroy
  has_many :lesson_slots, foreign_key: :instructor_id, dependent: :destroy
  accepts_nested_attributes_for :lesson_slots, allow_destroy: true

  has_one_attached :face_photo

  enum :role, { student: 0, instructor: 1, admin: 2 }

  LANGUAGES = %i[thai vietnamese lao khmer burmese].freeze
  FACE_PHOTO_CONTENT_TYPES = %w[image/png image/jpeg image/webp].freeze

  validates :name, presence: true
  validate :face_photo_must_be_an_image

  def recent_instructor
    lessons_as_student.order(created_at: :desc).first&.instructor
  end

  def instructable_languages
    LANGUAGES.select { |language| self["can_instruct_#{language}"] }
  end

  private

  def face_photo_must_be_an_image
    return unless face_photo.attached?
    return if face_photo.content_type.in?(FACE_PHOTO_CONTENT_TYPES)

    errors.add(:face_photo, "は画像ファイル(PNG, JPEG, WebP)を指定してください")
  end
end
