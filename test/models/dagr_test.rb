require 'test_helper'

class DagrTest < ActiveSupport::TestCase
  def setup
    @bob = users(:bob)
    @alice = users(:alice)
    @dagr = dagrs(:cat)
    @dagr_annotated = dagrs(:annotated)
    @shared = dagrs(:shared_dagr)
    @category = categories(:bobs_music)
  end
  
  test "get_dagr_annotions" do
    #first anotation is nil, so those atributes should be nil
    result = Dagr.get_dagr_annotations(@bob,@dagr)
    assert_equal(1,result.values.size)
    assert_equal("cat.txt",result[0]["file_name"])
    assert_nil(result[0]["name"])
    
    #now second should have annotations
    result = Dagr.get_dagr_annotations(@bob,@dagr_annotated)
    assert_equal(1,result.values.size)
    assert_equal("annotated.txt",result[0]["file_name"])
    assert_equal(result[0]["name"],"good_dog")
  end
  
  test "remove_dagrs" do
    Categorize.add_categorization(@category,@bob,@dagr_annotated)
    assert_difference 'Dagr.count',-1 do
      assert_difference 'Annotation.count', -1 do
        assert_difference 'UserHas.count', -1 do
          assert_difference 'Belong.count', -1 do
            assert_difference 'Categorize.count', -1 do
              assert_difference 'Category.count', 0 do
                assert_difference 'HasCategory.count', 0 do
                  @dagr_annotated.remove_dagr(@bob)
                end
              end
            end
          end
        end
      end
    end
    assert_difference 'Dagr.count',0 do
      assert_difference 'Annotation.count', 0 do
        assert_difference 'UserHas.count', -1 do
          assert_difference 'Belong.count', 0 do
            assert_difference 'Categorize.count', 0 do
              assert_difference 'Category.count', 0 do
                assert_difference 'HasCategory.count', 0 do
                  @shared.remove_dagr(@bob)
                end
              end
            end
          end
        end
      end
    end
  end
  
  test "adding_dagrs" do
    #bob = User.find(1)
    #alice = User.find(2)
    assert_difference 'Dagr.count', 2 do
      assert_difference 'Annotation.count', 0 do
        Dagr.add_dagr(@bob,"dog.txt","/home/bob",125,nil,nil)
      end
      assert_difference 'Annotation.count', 1 do
        dagr = Dagr.add_dagr(@bob,"lizard.txt","/home/bob",102,"my lizard",nil)
        annotation = Annotation.where(name: "my lizard").take
        user_has = UserHas.where(users_id: @bob.id, dagrs_guid: dagr.guid).take
        assert_equal(annotation.id,user_has.annotations_id)
        assert_not_nil(annotation)
        assert_not_nil(user_has)
      end
    end
    
     assert_difference 'Dagr.count', 1 do
      assert_difference 'Annotation.count', 1 do
        Dagr.add_dagr(@bob,"lizard2.txt","/home/bob",102,"my lizard","k1,k2")
      end
    end
    
    assert_difference 'Dagr.count', 0 do
      #bob already has a dagr cat.txt
      assert_difference 'UserHas.count', 0 do
        Dagr.add_dagr(@bob,"cat.txt","/home/bob",324,nil,nil)
      end
      #alice dose not, dagr count should stay 0, but a ferefrece for alice should be added
      assert_difference 'UserHas.count', 1 do
        Dagr.add_dagr(@alice,"cat.txt","/home/bob",102,nil,nil)
      end
    end
  end
end
