class Dagr < ApplicationRecord
  validates :name, uniqueness: {scope: :storage_path}
  
  require 'securerandom'
  
  def get_guid
    self.guid
  end
  
  #adds a new dagr to db, first 2 params self explanitory
  #name is the new name user is giving, keywords are the keywords
  #either name or keywords can be nilll but not both
  #!this dose not parse the document, it simply adds a dagr
  def self.add_dagr(user,file_name, storage_path,file_size, name, keywords)
    existing_dagr = Dagr.where(name: file_name, storage_path: storage_path).take
    
    #if there is not a existing dagr in db
    dagr = nil
    if !existing_dagr
      guid = SecureRandom.uuid
      dagr = Dagr.create(name: file_name, storage_path: storage_path, guid: guid, creator_name: user.name, file_size: file_size)
    else
      dagr = existing_dagr
    end
    
    #now there is dagr in db, add anotation if user specified
    annotation_id = nil
    if (name or keywords) #if name not nil or keywords not nil
      annotation_id = Annotation.create(name: name, keywords: keywords).id
    end
    
    #annotatiosn will now be nil or point to a record with at least onw non nil atribute
    #time to add a user_has to link the user,dagr,anotation  
    if !(UserHas.where(users_id: user.id, dagrs_guid: dagr.guid).take)
      UserHas.create(dagrs_guid: dagr.guid, users_id: user.id, annotations_id: annotation_id)
    else
      #this is fuzzy, if the user is inserting a dagr into the db that
      #he already has, do will edit anotations to be what the user specified
      #or do we not?
    end
    return dagr
  end
  
  #remove a dagr for this user including has_realtionship
  #cetegorizes, and all belongs that have this dagr
  #if this user is the only one that has this dagr ,the dagr is deleted
  def remove_dagr(user)
    has = UserHas.where(users_id: user.id, dagrs_guid: self[:guid]).take
    if (has)
      annotation_id = has.annotations_id
      UserHas.destroy(has.id)
      Annotation.destroy(annotation_id) if annotation_id != 0 
      Belong.remove_all_relationships(user,self)
      Categorize.remove_all_categorizations(self)
      
      #if no other user has this dagr, delete it
      if !UserHas.where(dagrs_guid: self[:guid]).take
        Dagr.destroy(self[:guid])
      end
    end
  end
  
  #this will be a query to get all dagr atributes in a hash
  #dagrs without anotaions will have nil atributes for name and keywords
  def self.get_dagr_annotations(user,dagr)
     execute (
             "select guid,dagrs.name as file_name,storage_path,creator_name,
              file_size,dagrs.created_at,dagrs.updated_at,annotations.name,keywords
              from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
              left join annotations on (annotations.id = user_has.annotations_id)
              where dagrs.guid = '#{dagr.guid}' and user_has.users_id = '#{user.id}';")
  end
  
  
  #make a dagr selfs child
  def add_child(user,child)
    return Belong.add_relationship(user,self,child)
  end
  
  #make dagr selfs parent
  def add_parent(user,parent)
    return Belong.add_relationship(user,parent,self)
  end
  
  #remove a dagr selfs child
  def remove_child(user,child)
    return Belong.remove_relationship(user,self,child)
  end
  
  #remove dagr selfs parent
  def remove_parent(user,parent)
    return Belong.remove_relationship(user,parent,self)
  end
  
end
