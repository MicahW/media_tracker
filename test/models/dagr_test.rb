require 'test_helper'

class DagrTest < ActiveSupport::TestCase
  test "adding_dagrs" do
    bob = User.find(1)
    alice = User.find(2)
    assert_difference 'Dagr.count', 2 do
      assert_difference 'Annotation.count', 0 do
        Dagr.add_dagr(bob,"dog.txt","/home/bob",125,nil,nil)
      end
      assert_difference 'Annotation.count', 1 do
        dagr = Dagr.add_dagr(bob,"lizard.txt","/home/bob",102,"my lizard",nil)
        annotation = Annotation.where(name: "my lizard").take
        user_has = UserHas.where(users_id: bob.id, dagrs_guid: dagr.guid).take
        assert_equal(annotation.id,user_has.annotations_id)
        assert_not_nil(annotation)
        assert_not_nil(user_has)
      end
    end
    
     assert_difference 'Dagr.count', 1 do
      assert_difference 'Annotation.count', 1 do
        Dagr.add_dagr(bob,"lizard2.txt","/home/bob",102,"my lizard","k1,k2")
      end
    end
    
    assert_difference 'Dagr.count', 0 do
      #bob already has a dagr cat.txt
      assert_difference 'UserHas.count', 0 do
        Dagr.add_dagr(bob,"cat.txt","/home/bob",324,nil,nil)
      end
      #alice dose not, dagr count should stay 0, but a ferefrece for alice should be added
      assert_difference 'UserHas.count', 1 do
        Dagr.add_dagr(alice,"cat.txt","/home/bob",102,nil,nil)
      end
    end
  end
end
