class Belong < ApplicationRecord
  validates :childs_guid, uniqueness: {scope: [:users_id, :parents_guid]}
  validate :not_same_guid
  
  def not_same_guid
    if childs_guid == parents_guid
      errors.add(:childs_guid, :invalid)
    end
  end
  
  
  
  #create a new realtionship between dagrs for user, assert user has each dagr
  def self.add_relationship(user,parent,child)
    if !(user.has_dagr?(parent) and user.has_dagr?(child))
      return nil
    end
    return Belong.create(users_id: user.id, parents_guid: parent.guid, childs_guid: child.guid)
  end
  
  #if there is a realtionship between the two dars, remove it
  def self.remove_relationship(user,parent,child)
      belong = Belong.where(users_id: user.id, parents_guid: parent.guid, childs_guid: child.guid).take
      if belong
        Belong.destroy(belong.id)
      end
  end
  
  #remove all the ralationships contaning that dagr and user
  def self.remove_all_relationships(user,dagr)
    execute("
    delete from belongs
    where users_id = '#{user.id}' and
    (parents_guid = '#{dagr.guid}' or 
     childs_guid = '#{dagr.guid}');")
  end
  
  #find all realtionships for this dagr, if parent true
  #find all parents, if false, find all children
  #only returns guids
  def self.find_all_relationships(user,dagr_guid,parent)
    if parent
      find_attr = "childs_guid"
      return_attr = "parents_guid"
    else
      find_attr = "parents_guid"
      return_attr = "childs_guid"
    end
       
    return execute("
    #{user_dagrs_with(user)},

    relatives_guids as
    (select #{return_attr} as guid from belongs
    where users_id = '#{user.id}' and
    #{find_attr} = '#{dagr_guid}')

    select * from user_dagrs 
    where guid in (select guid from relatives_guids);")

  end
  
  
end
