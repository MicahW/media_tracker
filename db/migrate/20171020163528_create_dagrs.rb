class CreateDagrs < ActiveRecord::Migration[5.1]
  def change
    create_table :dagrs, :id => false do |t|
      t.string :guid, null: false
      t.string :name, null: false
      t.string :storage_path, null: false
      t.string :creator_name, null: false
      t.timestamps
    end
    execute "ALTER TABLE dagrs ADD PRIMARY KEY (guid);"
  end
end
