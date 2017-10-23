class CreateCategorizes < ActiveRecord::Migration[5.1]
  def change
    create_table :categorizes do |t| 
      t.references :categories, index: true, foreign_key: true
      t.string :dagrs_guid, null: false, index: true
      t.timestamps
    end
    execute "ALTER TABLE categorizes ADD FOREIGN KEY (dagrs_guid) REFERENCES dagrs(guid);"
  end
end
