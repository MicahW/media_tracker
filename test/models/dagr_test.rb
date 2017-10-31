require 'test_helper'

class DagrTest < ActiveSupport::TestCase
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
  
  
  #QUERY TESTS
  test "reach querys1" do
    @q1.add_child(@sue,@q2)
    @q1.add_child(@sue,@q3)
    @q3.add_child(@sue,@q4)
    
    result = Dagr.reach_query(@sue,@q1,1,false)
    assert_equal(2,result.length)
    
    result = Dagr.reach_query(@sue,@q1,2,false)
    assert_equal(3,result.length)
  end
  
  test "reach query 2" do
  @q1.add_child(@sue,@q2)
  @q2.add_child(@sue,@q3)
  @q3.add_child(@sue,@q1)
  @q2.add_child(@sue,@q4)
  @q3.add_child(@sue,@q5)
  @q2.add_child(@sue,@q1)

  result = Dagr.reach_query(@sue,@q1,1,false)
  assert_equal(1,result.length)

  result = Dagr.reach_query(@sue,@q1,2,false)
  assert_equal(3,result.length)

  result = Dagr.reach_query(@sue,@q1,3,false)
  assert_equal(4,result.length)
  end
  
  test "reach query 3" do
  @q1.add_child(@sue,@q2)
  @q1.add_child(@sue,@q3)
  @q2.add_child(@sue,@q3)
  @q2.add_child(@sue,@q4)
  @q3.add_child(@sue,@q4)

  result = Dagr.reach_query(@sue,@q4,1,true)
  assert_equal(2,result.length)

  result = Dagr.reach_query(@sue,@q4,2,true)
  assert_equal(3,result.length)
  end
  
  test "orhpan and steril" do
    @q1.add_child(@sue,@q2)
    @q2.add_child(@sue,@q3)
    @q2.add_child(@sue,@q4)

    result = Dagr.orphan_sterile_query(@sue,true,false)
    assert_equal(2,result.values.length)
    
    result = Dagr.orphan_sterile_query(@sue,false,true)
    assert_equal(3,result.values.length)
    
    result = Dagr.orphan_sterile_query(@sue,true,true)
    assert_equal(1,result.values.length)
  end
    
  
  
  test "time_range_query" do
    result = Dagr.time_range_query(@sue,"2017-1-1 12:00:00","2017-1-3 12:00:00",true)
    assert_equal(3,result.values.length)
    
    result = Dagr.time_range_query(@sue,"2017-1-1 12:00:00","2017-1-1 12:30:00",true)
    assert_equal(2,result.values.length)
    
    result = Dagr.time_range_query(@sue,"2017-1-2 11:00:00","2017-1-2 12:30:00",false)
    assert_equal(1,result.values.length)
  end
    
  
  test "meta_data_query" do
    #(user,name,file_name,storage_path,keywords,author,type,size)
    result = Dagr.meta_data_query(
    @sue,nil,nil,nil,nil,nil,nil,nil,true)
    assert_equal(5,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,nil,"file",nil,nil,nil,nil,nil,true)
    assert_equal(1,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,nil,nil,nil,nil,nil,"mp3",nil,true)
    assert_equal(1,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,nil,nil,nil,nil,nil,nil,1233,true)
    assert_equal(1,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,nil,nil,"/home",nil,nil,nil,nil,true)
    assert_equal(1,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,"good",nil,nil,nil,nil,nil,nil,true)
    assert_equal(1,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,"file",nil,nil,nil,nil,nil,nil,true)
    assert_equal(2,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,nil,nil,nil,["file","text"],nil,nil,nil,true)
    assert_equal(2,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,nil,nil,nil,["file","text"],nil,nil,nil,false)
    assert_equal(2,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,nil,nil,nil,["file","text","good"],nil,nil,nil,true)
    assert_equal(1,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,nil,nil,nil,["file","text","good"],nil,nil,nil,false)
    assert_equal(2,result.values.length)
    
    result = Dagr.meta_data_query(
    @sue,"good_file","file.txt","/home/sue/files",["file","text","good"],"sue","txt",230,false)
    assert_equal(1,result.values.length)
    
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

    #test get all dagrs
    assert_equal(5,Dagr.get_all_dagrs(@sue).values.length)
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
