class UserHas < ApplicationRecord
  validates :dagrs_guid, uniqueness: {scope: [:users_id, :annotations_id]}
  
  def self.user_has_dagr?(user,dagr)
    relationship = UserHas.where(users_id: user.id, dagrs_guid: dagr.get_guid).take
    return (relationship != nil)
  end
end
