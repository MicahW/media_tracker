class Categorize < ApplicationRecord
  validates :dagrs_guid, uniqueness: {scope: :categories_id}
  
  
  #used to ADD new and MODIFY old
  #create a new link from this cataegory to a dagr
  #indictating that dagr belongs to this category
  def self.add_categorization(category,user,dagr)
    if user.has_dagr?(dagr) and category.has_category?(user)
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
      return Categorize.create(categories_id: category.id, dagrs_guid: dagr.get_guid)
    end
  end
  
  #remove dagr from whatever category its in
  def self.remove_dagrs_categorization(dagr)
    categorization = Categorize.where(dagrs_guid: dagr.guid).take
    Categorize.destroy(categorization.id) if categorization
  end
  
  #remove a specific dagr from a category
  def self.remove_categorization(category,user,dagr)
    if user.has_dagr?(dagr) and category.has_category?(user)
      categorization = Categorize.where(categories_id: category.id, dagrs_guid: dagr.guid).take
      if categorization != nil
        Categorize.destroy(categorization.id)
      end
    end
  end
  
  #remove all categorizations rerfrecing dagr
  def self.remove_all_categorizations(dagr)
    execute("
         delete
         from categorizes
         where dagrs_guid = '#{dagr.guid}';")
  end
    
  #removes all categorizations for this catgorie
  def self.remove_categorizations(category,user)
    if category.has_category?(user)
      execute("
         delete
         from categorizes
         where categories_id = '#{category.id}';")
    end
  end
end
