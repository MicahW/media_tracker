class Belong < ApplicationRecord
   validates :childs_guid, uniqueness: {scope: [:users_id, :parents_id]}

  
  
end
