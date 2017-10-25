class AddSizeToDagr < ActiveRecord::Migration[5.1]
  def change
    #file size in bytes
    add_column :dagrs, :file_size, :integer
  end
end
