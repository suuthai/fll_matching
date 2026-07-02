class AddZoomUrlToLessons < ActiveRecord::Migration[8.1]
  def change
    add_column :lessons, :zoom_url, :string
  end
end