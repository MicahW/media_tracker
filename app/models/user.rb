class User < ApplicationRecord
  require 'securerandom'
  
  #adds a new dagr to db, first 2 params self explanitory
  #name is the new name user is giving, keywords are the keywords
  #either name or keywords can be nilll but not both
  def add_dagr(file_name, storage_path, name, keywords)
    existing_dagr = Dagr.where(name: file_name, storage_path: storage_path).take
    
    #if there is not a existing dagr in db
    dagr = nil
    if !existing_dagr
      guid = SecureRandom.uuid
      dagr = Dagr.create(name: file_name, storage_path: storage_path, guid: guid, creator_name: self[:name])
    else
      dagr = existing_dagr
    end
    
    #now there is dagr in db, add anotation if user specified
    annotation = nil
    if (!name or !keywords) #if name not nil or keywords not nil
      annotation = Annotation.create(name: name, keywords: keywords)
    end
    
    #annotatiosn will now be nil or point to a record with at least onw non nil atribute
    #time to add a user_has to link the user,dagr,anotation  
    if !(UserHas.where(users_id: self[:id], dagrs_guid: dagr.guid).take)
      UserHas.create(dagrs_guid: dagr.guid, users_id: self[:id])
    else
      #this is fuzzy, if the user is inserting a dagr into the db that
      #he already has, do will edit anotations to be what the user specified
      #or do we not?
    end 
  end
end
