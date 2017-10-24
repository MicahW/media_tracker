class UserHas < ApplicationRecord
  validates :dagrs_guid, uniqueness: {scope: [:users_id, :annotations_id]}
end
