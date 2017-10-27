require 'test_helper'

class SubCategorieTest < ActiveSupport::TestCase
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
 
  test "add and remove categoreis" do
    abc = nil
    a = nil
    b = nil
    c = nil
    assert_difference 'SubCategorie.count', 4 do
      abc = Category.add_category(@bob,"abc")
      a = Category.add_category(@bob,"a")
      b = Category.add_category(@bob,"b")
      c = Category.add_category(@bob,"c")
      cc = Category.add_category(@bob,"cc")
      SubCategorie.add_relationship(abc,a)
      SubCategorie.add_relationship(abc,b)
      SubCategorie.add_relationship(abc,c)
      SubCategorie.add_relationship(c,cc)
      
      assert_equal(3, SubCategorie.find_children(abc).values.size,"1")
      assert_equal(0, SubCategorie.find_children(a).values.size,"2")
      assert_equal(0, SubCategorie.find_children(b).values.size,"3")
      assert_equal(1, SubCategorie.find_children(c).values.size,"4")
    
      assert_equal(0, SubCategorie.find_parents(abc).values.size,"5")
      assert_equal(1, SubCategorie.find_parents(b).values.size,"6")
      assert_equal(1, SubCategorie.find_parents(cc).values.size,"7")
    end
    
    assert_difference 'SubCategorie.count', -2 do
      assert_difference 'Category.count', 0 do
        SubCategorie.remove_relationship(abc,a)
        SubCategorie.remove_relationship(abc,b)
      end
    end
    assert_equal(1, SubCategorie.find_children(abc).values.size,"1")
    assert_equal(1, SubCategorie.find_children(c).values.size,"1")
    
  end
      
end
