class Category < ApplicationRecord
  #note many of these methods take a user
  #inputs where a category is already atached
  #to a user via has_categories
  #this is to prevent acdidental tampering of other
  #users categoreis
  
  
  #create a new catagory for a user with name of name
  def self.add_category(user,name)
    category = create(name: name)
    HasCategory.create(users_id: user.id, categories_id: category.id)
    return category
  end
  
  #remove this category, includeing all its relationships,
  #sub categoreies, categorizations, and has_category
  #asumming this should not remove all catgories bellow
  def remove_category(user)
    if has_category?(user)
      #remove all relationshanel entitys asocieted with this categorie
      SubCategorie.remove_all_relationships(self)
      remove_categorizations(user)
      has = HasCategory.where(users_id: user.id, categories_id: self[:id]).take
      HasCategory.destroy(has.id)
      Category.destroy(self[:id])
    end
  end

  #return true if this is the users categorie, and false otherwise
  def has_category?(user)
    has = HasCategory.where(users_id: user.id, categories_id: self[:id]).take
    return (has != nil)
  end
  
  #get a list of all dagrs in this category as pg::result
  def get_dagrs()
    result = execute("
    select *
    from categorizes join dagrs on (categorizes.dagrs_guid = dagrs.guid)
    where categorizes.categories_id = '#{self[:id]}';")
  end
  
  #same as get_dagrs but with id
  def self.get_dagrs_id(cat_id)
    result = execute("
    select dagrs.*
    from categorizes join dagrs on (categorizes.dagrs_guid = dagrs.guid)
    where categorizes.categories_id = '#{cat_id}';")
  end
  
  #used to ADD new and MODIFY old
  #create a new link from this cataegory to a dagr
  #indictating that dagr belongs to this category
  def add_categorization(user,dagr)
    if user.has_dagr?(dagr) and has_category?(user)
      #if this dagr already belonged to a categorie, now change it to be this one
        
        #first get a list of all the catogries id that ids of categories
        #that the user has
        #then find a categorization such that the user has the categorie, and
        #its pointing to that dagr
       old_categorizes = execute(
        "with users_categories as (
         select categories.id from
         users join has_categories on (users.id = has_categories.users_id)
         join categories on (has_categories.categories_id = categories.id)
         where users.id = '#{user.id}')

         select categorizes.id
         from categorizes
         where dagrs_guid = '#{dagr.get_guid}'
         and categories_id in (
         select id
         from users_categories);")
      #now that we have this if empty, no previus categorization, if not, 
      #delete that categorization
      
      if (old_categorizes.values.size == 1)
        old_id = old_categorizes[0]["id"]
        Categorize.destroy(old_id)
      elsif (old_categorizes.values.size > 1)
        puts "ERROR!!!! MULTIPLE CATEGEROIZATIONS FOR A DAGR"
        return nil
      end
       
      #now clear to create new categorization    
      return Categorize.create(categories_id: self[:id], dagrs_guid: dagr.get_guid)
    end
  end
  
  
  #get all categores this user has by user object
  def self.get_all_categories(user)
    execute("
    select *
    from categories join has_categories on (categories.id = has_categories.categories_id)
    where has_categories.users_id = '#{user.id}';")
  end
  
  #used for development purposes to display hierarchical struct
  def self.display_struct(struct, level)
    return if struct.empty?
    padding = ""
    (0..level).each do |i|
      padding += "   "
    end
    
    struct.each do |s|
      print padding
      print "id:#{s[0]}, name:#{s[1]}, dagrs:"
      s[2].each do |dagr| 
        print "#{dagr["name"]},"
      end
      puts ""
      display_struct(s[3],level+1)
    end
  end
  
  #returns a array structure of hierchal categroies
  # in format [[categorie_id,categorie_name,dagr_list_of_categorie,list_of_structs_for_categorie]]
  # a has dagrs 1,2 b has dagrs 3,4 b belongs to a [[a,[1,2],[b,[3,4],[]],[c,[],[]]]
  #remove a categorization between this category and dagr
  def self.get_hierarchical_struct(user)
    #start with each cataegorei at level 0
    struct = []
    start_cats = SubCategorie.get_all_at_zero(user)
    start_cats.each do |start|
      struct.push(get_struct(start))
    end
    return struct
  end
  
  #get the heirarchical display for this catagory
  #called recursivly to get heircachy
  def self.get_struct(categorie)
    #add id, name, and all its dagrs
    struct = [categorie["id"],categorie["name"]]
    struct.push get_dagrs_id(categorie["id"])
    
    #for each child crate a new structre and add it
    children = SubCategorie.find_children_by_id(categorie["id"])
    
    #a structure for each child
    children_struct = []
    children.each do |child|
      children_struct.push(get_struct(child))
    end
    
    
    #add children struct as last thing in list
    struct.push(children_struct)
    return struct
  end
    
  #remove a specific dagr from a category
  def remove_categorization(user,dagr)
    if user.has_dagr?(dagr) and has_category?(user)
      categorization = Categorize.where(categories_id: self[:id], dagrs_guid: dagr.guid).take
      if categorization != nil
        Categorize.destroy(categorization.id)
      end
    end
  end
    
  #removes all categorizations for this catgorie
  def remove_categorizations(user)
    if has_category?(user)
      execute("
         delete
         from categorizes
         where categories_id = '#{self[:id]}';")
    end
  end
end

