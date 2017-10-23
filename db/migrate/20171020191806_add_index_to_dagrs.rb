class AddIndexToDagrs < ActiveRecord::Migration[5.1]
  def change
    add_index :dagrs, :name
    add_index :dagrs, :storage_path
  end
end
