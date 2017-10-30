require 'test_helper'

class AnnotationTest < ActiveSupport::TestCase
   def setup
    @bob = users(:bob)
    @alice = users(:alice)
    @dagr = dagrs(:cat)
    @dagr_annotated = dagrs(:annotated)
    @shared = dagrs(:shared_dagr)
    @category = categories(:bobs_music)
    @sue = users(:sue)
    
    @q1 = dagrs(:query1)
    @q2 = dagrs(:query2)
    @q3 = dagrs(:query3)
    @q4 = dagrs(:query4)
    @q5 = dagrs(:query5)
  end
  
  test "add annotations" do
    assert_difference 'Annotation.count', 0 do
      Annotation.add_annotation(@bob,@dagr,nil,nil)
    end
    
    assert_difference 'Annotation.count', 1 do
      Annotation.add_annotation(@bob,@dagr,"name","k1,k2,k3")
    end
    
    assert_difference 'Annotation.count', 0 do
      ann = Annotation.add_annotation(@bob,@dagr,"new_name",nil)
      assert_equal("new_name",ann.name)
      assert_equal("k1,k2,k3",ann.keywords)
      assert_equal("k1,k2,k3",ann.keywords)
    end
    
    assert_difference 'Annotation.count', -1 do
      Annotation.remove_annotation(@bob,@dagr)
    end
    
  end
    
end
