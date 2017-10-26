class User < ApplicationRecord
  
  
  #there are a list of methods defined in thier respective modles
  #they can be cionviently called on from a user object via these guys
  
  def add_dagr(file_name, storage_path,file_size, name, keywords)
    Dagr.add_dagr(self, file_name, storage_path, file_size, name, keywords)
  end
  
  def has_dagr?(dagr) 
    UserHas.user_has_dagr?(self,dagr)
  end
  
  def add_category(name)
    Category.add_category(self, name)
  end
  
end
