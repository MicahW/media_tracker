require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  def setup
    @bob = users(:bob)
    @alice = users(:alice)
    @dagr = dagrs(:cat)
    @dagr2 = dagrs(:annotated)
    @cat = categories(:bobs_shapes)
    @cat2 = categories(:bobs_foods)
    @alices_cat = categories(:alices_shapes)
    @alices_dagr = dagrs(:alices_dagr)
    @shared_dagr = dagrs(:shared_dagr)
  end
  
  test "simple add test" do
    assert_difference 'Category.count', 1 do
      assert_difference 'HasCategory.count', 1 do
        category = @bob.add_category("test_files")
        has = HasCategory.where(users_id: @bob.id, categories_id: category.id).take
        assert_not_nil(has)
      end
    end
  end
  
  test "add_modify_categorization" do
    #put dagr in cat
    assert_difference 'Categorize.count', 1 do
      link = @cat.add_categorization(@bob,@dagr)
      assert_equal(@cat.id, link.categories_id)
      assert_equal(@dagr.get_guid, link.dagrs_guid)
    end
    
    #puts dagr in cat again
    assert_difference 'Categorize.count', 0 do
      @cat.add_categorization(@bob,@dagr)
    end
    
    #put dagr in cat2
    assert_difference 'Categorize.count', 0 do
      link = @cat2.add_categorization(@bob,@dagr)
      assert_equal(@cat2.id, link.categories_id)
      assert_equal(@dagr.get_guid, link.dagrs_guid)
    end
    
    #put dagr2 in cat2
    assert_difference 'Categorize.count', 1 do
      link = @cat2.add_categorization(@bob,@dagr2)
      assert_equal(@cat2.id, link.categories_id)
      assert_equal(@dagr2.get_guid, link.dagrs_guid)
    end
    
    #alices trys to add dagr she dose not have
    assert_difference 'Categorize.count', 0 do
      link = @alices_cat.add_categorization(@alice,@dagr)
    end
    
    #alices trys to add dagr to cat she dose not have
    assert_difference 'Categorize.count', 0 do
      link = @cat2.add_categorization(@alice,@alices_dagr)
    end
    
    #alices trys to add legit dagr to catagorie
    assert_difference 'Categorize.count', 1 do
      link = @alices_cat.add_categorization(@alice,@alices_dagr)
      assert_equal(@alices_cat.id, link.categories_id)
      assert_equal(@alices_dagr.get_guid, link.dagrs_guid)
    end
    
    #both bob and alice add a shared dagr to category
    assert_difference 'Categorize.count', 2 do
      link = @cat2.add_categorization(@bob,@shared_dagr)
      assert_equal(@cat2.id, link.categories_id)
      assert_equal(@shared_dagr.get_guid, link.dagrs_guid)
      
      link = @alices_cat.add_categorization(@alice,@shared_dagr)
      assert_equal(@alices_cat.id, link.categories_id)
      assert_equal(@shared_dagr.get_guid, link.dagrs_guid)
    end   
  end     
end
