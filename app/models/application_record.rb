class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def self.user_dagrs_with(user)
    str = "with temp_user_dagrs as (
      select guid,dagrs.name as file_name,storage_path,creator_name,
      file_size,dagrs.created_at as created_at,user_has.created_at as added_at,annotations.name as name,keywords,
      file_size as size

      from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
      left join annotations on (annotations.id = user_has.annotations_id)
      where user_has.users_id = '#{user.id}'),
  
      dagr_categories as (
      select dagrs.guid as in_category_guid, categories.name as category_name
      from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
      join annotations on (annotations.id = user_has.annotations_id)
      join categorizes on (dagrs.guid = categorizes.dagrs_guid)
      join categories on (categorizes.categories_id = categories.id)
      join has_categories on (categories.id = has_categories.categories_id)
      where has_categories.users_id = '#{user.id}'),

      user_dagrs as (
      select *
      from temp_user_dagrs left join dagr_categories on
        (temp_user_dagrs.guid = dagr_categories.in_category_guid))"
    
   return str
  end
  

  
  #pain to type this out so now just execute()
  def self.execute(str)
    ActiveRecord::Base.connection.execute(str)
  end
  def execute(str)
    ActiveRecord::Base.connection.execute(str)
  end
  
  
end
