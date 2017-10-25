class ChangeBelongUserToUsersId < ActiveRecord::Migration[5.1]
  def change
    rename_column :belongs, :user_id, :users_id
  end
end
