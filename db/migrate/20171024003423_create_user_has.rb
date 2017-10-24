class CreateUserHas < ActiveRecord::Migration[5.1]
  def change
    create_table :user_has do |t|
      t.references :user, index: true, foreign_key: true
      t.string :dagrs_guid, null: false, index: true
      t.references :annotations, foreign_key: true, null: true
      t.timestamps
    end
    execute "ALTER TABLE user_has ADD FOREIGN KEY (dagrs_guid) REFERENCES dagrs(guid);"
  end
end
