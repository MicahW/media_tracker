class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name, length: 1..30
      t.string :password, length: 1..30
      t.timestamps
    end
  end
end
