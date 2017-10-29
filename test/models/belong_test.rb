require 'test_helper'

class BelongTest < ActiveSupport::TestCase
  def setup
    @bob = users(:bob)
    @alice = users(:alice)
    @dagr = dagrs(:news1)
    @dagr2 = dagrs(:news2)
  end
  
  test "add and remove realtionships" do
    #adding
    assert_difference 'Belong.count', 1 do
      @dagr.add_parent(@bob,@dagr2)
    end
    assert_difference 'Belong.count', 0 do
      @dagr.add_parent(@bob,@dagr2)
    end
    assert_difference 'Belong.count', 0 do
      @dagr2.add_child(@bob,@dagr)
    end
    assert_difference 'Belong.count', 1 do
      @dagr.add_child(@bob,@dagr2)
    end
    assert_no_difference 'Belong.count', 0 do
      @dagr.add_parent(@alice,@dagr2)
      @dagr.add_parent(@alice,@dagr2)
    end
    
    #removeing
    assert_difference 'Belong.count', -1 do
      @dagr.remove_parent(@bob,@dagr2)
    end
    assert_difference 'Belong.count', 0 do
      @dagr.remove_parent(@bob,@dagr2)
    end
    assert_difference 'Belong.count', 0 do
      @dagr.remove_parent(@alice,@dagr2)
    end
    assert_difference 'Belong.count', 0 do
      @dagr2.remove_parent(@alice,@dagr)
    end
    assert_difference 'Belong.count', -1 do
      @dagr.remove_child(@bob,@dagr2)
    end
    
  end
end
