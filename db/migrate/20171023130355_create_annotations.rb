class CreateAnnotations < ActiveRecord::Migration[5.1]
  def change
    create_table :annotations do |t|
      t.string :name, null: false
      t.string :keywords, null: false
      t.timestamps
    end
  end
end
