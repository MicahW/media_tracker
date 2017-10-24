class Categorize < ApplicationRecord
  validates :dagrs_guid, uniqueness: {scope: :categories_id}
end
