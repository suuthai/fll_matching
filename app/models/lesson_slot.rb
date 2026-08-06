class LessonSlot < ApplicationRecord
  belongs_to :instructor, class_name: "User"

  enum :language, User::LANGUAGES
end
