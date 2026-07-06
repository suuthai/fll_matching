class AddCanInstructColumnsToUsers < ActiveRecord::Migration[8.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  LANGUAGE_VALUES_BY_COLUMN = {
    can_instruct_thai: 0,
    can_instruct_vietnamese: 1,
    can_instruct_lao: 2,
    can_instruct_khmer: 3,
    can_instruct_burmese: 4
  }.freeze

  def up
    LANGUAGE_VALUES_BY_COLUMN.each_key do |column|
      add_column :users, column, :boolean, default: false, null: false
    end
    MigrationUser.reset_column_information

    LANGUAGE_VALUES_BY_COLUMN.each do |column, value|
      MigrationUser.where(instructional_language: value).update_all(column => true)
    end

    remove_column :users, :instructional_language
    MigrationUser.reset_column_information
  end

  def down
    add_column :users, :instructional_language, :integer
    MigrationUser.reset_column_information

    LANGUAGE_VALUES_BY_COLUMN.each do |column, value|
      MigrationUser.where(column => true).update_all(instructional_language: value)
    end

    LANGUAGE_VALUES_BY_COLUMN.each_key do |column|
      remove_column :users, column
    end
    MigrationUser.reset_column_information
  end
end
