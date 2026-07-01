class AddNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    User.update_all(name: "(未設定)")
    change_column_null :users, :name, false
  end
end
