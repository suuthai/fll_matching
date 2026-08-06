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

ActiveRecord::Schema[8.1].define(version: 2026_07_13_091942) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "lesson_slots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "hour", null: false
    t.bigint "instructor_id", null: false
    t.integer "language", null: false
    t.datetime "updated_at", null: false
    t.index ["instructor_id", "hour", "language"], name: "index_lesson_slots_on_instructor_id_and_hour_and_language", unique: true
    t.index ["instructor_id"], name: "index_lesson_slots_on_instructor_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "instructor_id", null: false
    t.datetime "starts_at", null: false
    t.bigint "student_id", null: false
    t.datetime "updated_at", null: false
    t.string "zoom_url"
    t.index ["instructor_id", "starts_at"], name: "index_lessons_on_instructor_id_and_starts_at", unique: true
    t.index ["instructor_id"], name: "index_lessons_on_instructor_id"
    t.index ["student_id", "starts_at"], name: "index_lessons_on_student_id_and_starts_at", unique: true
    t.index ["student_id"], name: "index_lessons_on_student_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "can_instruct_burmese", default: false, null: false
    t.boolean "can_instruct_khmer", default: false, null: false
    t.boolean "can_instruct_lao", default: false, null: false
    t.boolean "can_instruct_thai", default: false, null: false
    t.boolean "can_instruct_vietnamese", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.text "profile_text"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "tickets_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "lesson_slots", "users", column: "instructor_id"
  add_foreign_key "lessons", "users", column: "instructor_id"
  add_foreign_key "lessons", "users", column: "student_id"
end
