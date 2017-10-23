class CreateBelongs < ActiveRecord::Migration[5.1]
  def change
    create_table :belongs do |t|
      t.string :parents_guid, null: false, index: true
      t.string :childs_guid, null: false, index: true
      t.timestamps
    end
    execute "ALTER TABLE belongs ADD FOREIGN KEY (parents_guid) REFERENCES dagrs(guid);"
    execute "ALTER TABLE belongs ADD FOREIGN KEY (childs_guid) REFERENCES dagrs(guid);"
  end
end

