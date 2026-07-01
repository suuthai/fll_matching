# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_01_033322) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "lessons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "instructor_id", null: false
    t.datetime "starts_at", null: false
    t.bigint "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["instructor_id", "starts_at"], name: "index_lessons_on_instructor_id_and_starts_at", unique: true
    t.index ["instructor_id"], name: "index_lessons_on_instructor_id"
    t.index ["student_id", "starts_at"], name: "index_lessons_on_student_id_and_starts_at", unique: true
    t.index ["student_id"], name: "index_lessons_on_student_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "instructional_language"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "tickets_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "lessons", "users", column: "instructor_id"
  add_foreign_key "lessons", "users", column: "student_id"
end
