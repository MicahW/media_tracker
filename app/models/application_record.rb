class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def self.user_dagrs_with(user)
    str = "with user_dagrs as (
      select guid,dagrs.name as file_name,storage_path,creator_name,
      file_size,dagrs.created_at as created_at,user_has.created_at as added_at,annotations.name as name,keywords,
      file_size as size

      from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
      left join annotations on (annotations.id = user_has.annotations_id)
      where user_has.users_id = '#{user.id}')"
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
