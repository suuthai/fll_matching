class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.datetime :starts_at, null: false

      t.timestamps
    end

    add_index :lessons, [ :student_id, :starts_at ], unique: true
    add_index :lessons, [ :instructor_id, :starts_at ], unique: true
  end
end
