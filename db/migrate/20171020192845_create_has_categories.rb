class CreateHasCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :has_categories do |t|
      t.references :users, index: true, foreign_key: true
      t.references :categories, index: true, foreign_key: true
      t.timestamps
    end
  end
end
