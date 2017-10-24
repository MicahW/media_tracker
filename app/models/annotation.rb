class Annotation < ApplicationRecord
  validate :has_one_value
  
  def has_one_value
    if !name && !keywords
      errors.add(:name, :invalid)
    end
  end
end
