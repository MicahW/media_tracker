class HasCategory < ApplicationRecord
  validates :categories_id, uniqueness: {scope: :users_id}
end
