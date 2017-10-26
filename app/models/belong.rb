class Belong < ApplicationRecord
  validates :childs_guid, uniqueness: {scope: [:users_id, :parents_guid]}

  
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
  
end
