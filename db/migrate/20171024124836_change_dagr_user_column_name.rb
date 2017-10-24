class ChangeDagrUserColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :user_has, :user_id, :users_id
  end
end
