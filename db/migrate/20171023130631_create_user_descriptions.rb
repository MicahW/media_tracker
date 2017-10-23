class CreateUserDescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_descriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.string :dagrs_guid, null: false, index: true
      t.references :annotations, foreign_key: true
      t.timestamps
    end
    execute "ALTER TABLE user_descriptions ADD FOREIGN KEY (dagrs_guid) REFERENCES dagrs(guid);"
  end
end
