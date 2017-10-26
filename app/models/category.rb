class Category < ApplicationRecord
  
  #create a new catagory for a user with name of name
  def self.add_category(user,name)
    category = create(name: name)
    HasCategory.create(users_id: user.id, categories_id: category.id)
    return category
  end
  
  #return true if this is the users categorie, and false otherwise
  def has_category?(user)
    has = HasCategory.where(users_id: user.id, categories_id: self[:id]).take
    return (has != nil)
  end
  
  #used to add new and modifie old
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
  
end
