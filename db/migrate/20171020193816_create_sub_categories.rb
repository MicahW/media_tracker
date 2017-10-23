class CreateSubCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :sub_categories do |t|
      t.integer :parents_id, null: false
      t.integer :childs_id, null: false 
      t.timestamps
    end
     execute "ALTER TABLE sub_categories ADD FOREIGN KEY (parents_id) REFERENCES categories(id);"
     execute "ALTER TABLE sub_categories ADD FOREIGN KEY (childs_id) REFERENCES categories(id);"
  end
end
