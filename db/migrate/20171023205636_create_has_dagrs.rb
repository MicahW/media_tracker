class CreateHasDagrs < ActiveRecord::Migration[5.1]
  def change
    def change
    create_table :has_dagrs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :dagrs_guid, null: false, index: true
      t.references :annotations, foreign_key: true, null: true
      t.timestamps
    end
    execute "ALTER TABLE has_dagrs ADD FOREIGN KEY (dagrs_guid) REFERENCES dagrs(guid);"
  end
  end
end
