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
    
    @bobs_music = categories(:bobs_music)
    @bobs_media = categories(:bobs_music)
    @alices_music = categories(:alices_music)
    @music1 = dagrs(:music1)
    @music2 = dagrs(:music2)
    @music3 = dagrs(:music3)
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
  
  test "remove categorization" do 
    assert_difference 'Categorize.count', 0 do
      @bobs_music.remove_categorization(@alice,@music1)
    end
    assert_difference '@bobs_music.get_dagrs().values.size', -1 do
      assert_difference '@alices_music.get_dagrs().values.size', 0 do
        @bobs_music.remove_categorization(@bob,@music1)
      end
    end
    
    assert_difference '@bobs_music.get_dagrs().values.size', -2 do
      assert_difference '@alices_music.get_dagrs().values.size', 0 do
        @bobs_music.remove_categorizations(@bob)
      end
    end
  end
      
  
  test "get dagrs in categorie" do
    assert_difference 'Category.count', 0 do
      assert_difference 'Categorize.count', 0 do
        guids = ["00000000-0000-0000-0000-000000000001",
                  "00000000-0000-0000-0000-000000000002",
                  "00000000-0000-0000-0000-000000000003"]
        dagrs = @bobs_music.get_dagrs()
        assert_equal(3,dagrs.values.size)
        assert(guids.include?(dagrs[0]["guid"]))
        assert(guids.include?(dagrs[1]["guid"]))
        assert(guids.include?(dagrs[2]["guid"]))
        
        dagrs = @alices_music.get_dagrs()
        assert_equal(3,dagrs.values.size)
        assert(guids.include?(dagrs[0]["guid"]))
        assert_equal(3,dagrs.values.size)
        assert(guids.include?(dagrs[1]["guid"]))
        assert_equal(3,dagrs.values.size)
        assert(guids.include?(dagrs[2]["guid"]))
        
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
