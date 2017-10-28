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
  
  
end
