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
  
  test "remove all relationships" do
    assert_difference 'SubCategorie.count', 1 do
      abc = Category.add_category(@bob,"abc")
      a = Category.add_category(@bob,"a")
      b = Category.add_category(@bob,"b")
      c = Category.add_category(@bob,"c")
      cc = Category.add_category(@bob,"cc")
      SubCategorie.add_relationship(abc,a)
      SubCategorie.add_relationship(abc,b)
      SubCategorie.add_relationship(abc,c)
      SubCategorie.add_relationship(c,cc)
      SubCategorie.remove_all_relationships(abc)
    end
  end
 
  test "add and remove sub categoreis" do
    abc = nil
    a = nil
    b = nil
    c = nil
    cc = nil
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
      
      
      struct = Category.get_hierarchical_struct(@bob)
      struct.each do |s|
        if s[1] == "abc"
          assert(s[2].values.empty?)
          assert_equal(s[3].size,3,"test size")
        elsif s[1] == "media"
          dagr_guids = get_guids(s[2])
          assert(dagr_guids.include?("00000000-0000-0000-0000-000000000012"),"dagrs 2")
          assert(dagr_guids.include?("00000000-0000-0000-0000-000000000011"),"dagrs 1")
        end
      end
      
      zeros = SubCategorie.get_all_at_zero(@bob)
      assert_equal(4, zeros.values.size,"at zero size")

      
      assert_equal(4, SubCategorie.get_decendents(abc).size,"111")
      assert_equal(0, SubCategorie.get_decendents(b).size,"111")
      assert_equal(1, SubCategorie.get_decendents(c).size,"111")
      
      #try to  make categories that are already subcateogreis cataegoreis
      #and try to add previud relationships
      assert_difference 'SubCategorie.count', 0 do
        SubCategorie.add_relationship(abc,a)
        SubCategorie.add_relationship(abc,cc)
        SubCategorie.add_relationship(b,cc)
        SubCategorie.add_relationship(a,abc)
        SubCategorie.add_relationship(cc,abc)
      end
      
      
      
      assert_equal(3, SubCategorie.find_children(abc).values.size,"1")
      assert_equal(0, SubCategorie.find_children(a).values.size,"2")
      assert_equal(0, SubCategorie.find_children(b).values.size,"3")
      assert_equal(1, SubCategorie.find_children(c).values.size,"4")
    
      assert_equal(0, SubCategorie.get_level(abc),"11")
      assert_equal(1, SubCategorie.get_level(a),"12")
      assert_equal(1, SubCategorie.get_level(b),"13")
      assert_equal(1, SubCategorie.get_level(c),"14")
      assert_equal(2, SubCategorie.get_level(cc),"15")
      
      assert_equal(0, SubCategorie.find_parents(abc).values.size,"5")
      assert_equal(1, SubCategorie.find_parents(b).values.size,"6")
      assert_equal(1, SubCategorie.find_parents(cc).values.size,"7")
    end
    
    assert_difference 'SubCategorie.count', -2 do
      assert_difference 'Category.count', 0 do
        SubCategorie.remove_relationship(abc,a)
        SubCategorie.remove_relationship(abc,c)
        assert_equal(0, SubCategorie.get_level(a),"17")
        assert_equal(1, SubCategorie.get_level(cc),"16")
      end
    end
    assert_equal(1, SubCategorie.find_children(abc).values.size,"1")
    assert_equal(1, SubCategorie.find_children(c).values.size,"1")  
  end  
end
