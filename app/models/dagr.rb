class Dagr < ApplicationRecord
  validates :name, uniqueness: {scope: :storage_path}
end
