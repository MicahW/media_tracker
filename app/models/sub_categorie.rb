class SubCategorie < ApplicationRecord
  validates :childs_id, uniqueness: {scope: :parents_id}
  validate :not_same_id
  
  def not_same_id
    if childs_id == parents_id
      errors.add(:childs_id, :invalid)
    end
  end
  
  #add a new relationshuip between parents and chilren
  #can make a categorie a sub categorie if not already a
  #subcategori ie at level 0
  def self.add_relationship(parent,child)
    if get_level(child) == 0 and !get_decendents(child).include?(parent.id)
      return SubCategorie.create(parents_id: parent.id, childs_id: child.id)
    end
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
    select parents_id
    from sub_categories
    where childs_id = '#{child.id}';")
  end
  
  #remove all ocurences of this relationship
  def self.remove_all_relationships(category)
    execute("
    delete from sub_categories
    where parents_id = '#{category.id}'
    or childs_id = '#{category.id}';")
  end
    
  
  #returns the level of this categorie 
  #starting at level 0
  def self.get_level(category)
    level = 0
    result = find_parents(category)
    while(result.values.size != 0)
      level += 1
      category = Category.find(result[0]["parents_id"].to_i)
      result = find_parents(category)
    end
    return level
  end
  
  #this is a super fun one
  #get all decendents of category
  #return thier ids
  def self.get_decendents(category)
    ids = []
    results = find_children(category)
    results.each do |record|
      child = Category.find(record["childs_id"].to_i)
      ids.push child.id
      get_decendents(child).each do |c|
        ids.push(c)
      end
    end
    return ids.uniq
  end
  
end
