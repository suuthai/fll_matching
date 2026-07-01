class AddInstructionalLanguageToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :instructional_language, :integer
  end
end
