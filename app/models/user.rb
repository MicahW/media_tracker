class User < ApplicationRecord
  
  def has_dagr?(dagr) 
    UserHas.user_has_dagr?(self,dagr)
  end
  
end
