class AllowNullInAnnotations < ActiveRecord::Migration[5.1]
  def change
    change_column_null :annotations, :name, true
    change_column_null :annotations, :keywords, true
  end
end
