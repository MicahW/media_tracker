require 'test_helper'

class UserHasTest < ActiveSupport::TestCase
  test "adding_dagrs" do
    bob = User.find(1)
    alice = User.find(2)
    assert_difference 'Dagr.count', 2 do
      assert_difference 'Annotation.count', 0 do
        bob.add_dagr("dog.txt","/home/bob",nil,nil)
      end
      assert_difference 'Annotation.count', 1 do
        bob.add_dagr("lizard.txt","/home/bob","my lizard",nil)
      end
    end
    assert_difference 'Dagr.count', 0 do
      #bob already has a dagr cat.txt
      assert_difference 'UserHas.count', 0 do
        bob.add_dagr("cat.txt","/home/bob",nil,nil)
      end
      #alice dose not, dagr count should stay 0, but a ferefrece for alice should be added
      assert_difference 'UserHas.count', 1 do
        alice.add_dagr("cat.txt","/home/bob",nil,nil)
      end
    end
  end
end
