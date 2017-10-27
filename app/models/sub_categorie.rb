class SubCategorie < ApplicationRecord
  validates :childs_id, uniqueness: {scope: :parents_id}
  validate :not_same_id
  
  def not_same_id
    if childs_id == parents_id
      errors.add(:childs_id, :invalid)
    end
  end
  
  #add a new relationshuip between parents and chilren
  def self.add_relationship(parent,child)
    return SubCategorie.create(parents_id: parent.id, childs_id: child.id)
  end
  
  #removes relationship
  def self.remove_relationship(parent,child)
    old = SubCategorie.where(parents_id: parent.id, childs_id: child.id).take
    if old != nil
      SubCategorie.destroy(old.id)
    end
  end
  
  #find all chilfren of this catagorie
  def self.find_children(parent)
    execute("
    select childs_id
    from sub_categories
    where parents_id = '#{parent.id}';")
  end
  
  #find all parents
  def self.find_parents(child)
    execute("
    select childs_id
    from sub_categories
    where childs_id = '#{child.id}';")
  end
end
