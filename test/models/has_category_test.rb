require 'test_helper'

class HasCategoryTest < ActiveSupport::TestCase
  test "unique_foreign_keys" do
    Category.create(:id => 2, :name => "colors")
    assert_difference 'HasCategory.count' do
      HasCategory.create(:users_id => 1, :categories_id => 2)
    end
    assert_no_difference 'HasCategory.count' do
      HasCategory.create(:users_id => 1, :categories_id => 1)
    end
  end
end
