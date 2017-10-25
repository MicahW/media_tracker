require 'test_helper'

class BelongTest < ActiveSupport::TestCase
  def setup
    @bob = users(:bob)
    @alice = users(:alice)
    @dagr = dagrs(:cat)
    @dagr2 = dagrs(:annotated)
  end
  
  test "add realtionships" do
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
  end
end
