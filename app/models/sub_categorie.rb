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
  
  #find children by object
  def self.find_children(parent)
    find_children_by_id(parent.id)
  end
  
  #find parents by object
  def self.find_parents(child)
    find_parents_by_id(child.id)
  end
  
  
  #find all chilfren of this catagorie
  def self.find_children_by_id(parent)
    execute("
    with child_cats as (
    select childs_id
    from sub_categories
    where parents_id = '#{parent}')

    select *
    from categories
    where categories.id in 
    (select childs_id from child_cats);")

  end 
  
  #find all parents
  def self.find_parents_by_id(child)
    execute("
    select parents_id
    from sub_categories
    where childs_id = '#{child}';")
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
      child = Category.find(record["id"].to_i)
      ids.push child.id
      get_decendents(child).each do |c|
        ids.push(c)
      end
    end
    return ids.uniq
  end
  
  #now find all categories at level 0)
  def self.get_all_at_zero(user)
    execute("
    with user_categories as (
    select categories.id, categories.name
    from categories join has_categories on 
    (categories.id = has_categories.categories_id)
    where has_categories.users_id = '#{user.id}')
    
    select *
    from user_categories
    where user_categories.id not in (

    select childs_id
    from sub_categories);")
  end


  
end













