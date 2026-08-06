class CreateLessonSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_slots do |t|
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.integer :hour, null: false
      t.integer :language, null: false

      t.timestamps
    end
    
    add_index :lesson_slots, [ :instructor_id, :hour, :language ], unique: true
  end
end
