class Belong < ApplicationRecord
  validates :childs_guid, uniqueness: {scope: [:users_id, :parents_guid]}

  def self.add_relationship(user,parent,child)
    return Belong.create(users_id: user.id, parents_guid: parent.guid, childs_guid: child.guid)
  end
  
  
end
