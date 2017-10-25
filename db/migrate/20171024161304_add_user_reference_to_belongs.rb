class AddUserReferenceToBelongs < ActiveRecord::Migration[5.1]
  def change
    add_reference :belongs, :user, index: true, null: false
  end
end
