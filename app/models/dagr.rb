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
      dagr = Dagr.create(name: file_name, storage_path: storage_path, guid: guid, 
        creator_name: user.name, file_size: file_size)
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
      #return nil
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
              file_size,dagrs.created_at,dagrs.updated_at,annotations.name,keywords, file_size
              from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
              left join annotations on (annotations.id = user_has.annotations_id)
              where dagrs.guid = '#{dagr.guid}' and user_has.users_id = '#{user.id}';")
  end
  
  #returns all the dagrs for this user
  def self.get_all_dagrs(user)
    execute (
             "select guid,dagrs.name as file_name,storage_path,creator_name,
              file_size,dagrs.created_at,dagrs.updated_at,annotations.name,keywords, file_size
              from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
              left join annotations on (annotations.id = user_has.annotations_id)
              where user_has.users_id = '#{user.id}';")
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
  
  #QUERYS
  
  #find all dagrs by attributes,for user
  #any atrributes that are nill will not be used
  #user is object, all others strings
  #keywords is a list of keywords
  #all keywords is a boolean specifing wetherall keywords must be met, or any of them
  def self.meta_data_query(
        user,name,file_name,storage_path,keywords,author,type,size,all_keywords)
    #will be k1 or k2 or will be k1 and k2 depedning if all or no keywords
    all = "and" if all_keywords
    all = "or" if !all_keywords
    
    #this will be the sql where clause
    clause = ""
    if file_name
      clause += "(file_name like '#{file_name}.%' 
      or file_name = '#{file_name}' ) and "
    end
    clause += "storage_path = '#{storage_path}' and " if storage_path
    clause += "(name like '%#{name}%' or (name = null and file_name like '%#{name}%')) and " if name
    clause += "creator_name like '%#{author}%' and " if author
    clause += "size = #{size} and " if size
    clause += "file_name like '%#{type}' and " if type
    if keywords
      clause += "(("
      keywords.each do |keyword|
        clause += "keywords like '%#{keyword}%' #{all} "
      end
      #get rid of the last or
      clause = clause[0..(clause.length - 5)] if all_keywords
      clause = clause[0..(clause.length - 4)] if !all_keywords
      clause += ") or keywords = null) and "
    end
    #get rid of last and
    where = ""
    if clause != ""
      clause = clause[0..(clause.length - 5)]
      where = "where"
    end
    #puts clause
  
    return execute("
    with user_dagrs as (
    select guid,dagrs.name as file_name,storage_path,creator_name,
    file_size,dagrs.created_at,dagrs.updated_at,annotations.name as name,keywords,file_size as size
    from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
    left join annotations on (annotations.id = user_has.annotations_id)
    where user_has.users_id = '#{user.id}')

    select *
    from user_dagrs
    #{where} #{clause} ;")
  end
  
  #this will query for dagrs in time range
  #created-> true then find by created_at
  #created-> false then updated_at
  def self.time_range_query(user,start_time,end_time,created)
    attr = "created_at" if created
    attr = "updated_at" if !created
    
    clause = "#{attr} between '#{start_time}' and '#{end_time}'" 
    
    return execute("
    with user_dagrs as (
    select guid,dagrs.name as file_name,storage_path,creator_name,
    file_size,dagrs.created_at,dagrs.updated_at,annotations.name as name,keywords,
    file_size as size

    from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
    left join annotations on (annotations.id = user_has.annotations_id)
    where user_has.users_id = '#{user.id}')

    select *
    from user_dagrs
    where #{clause} ;")
  end
  
  #find all dagrs that are orphans or sterile, last 2 parameters are booleans
  def self.orphan_sterile_query(user,orphan,sterile)
    orphan_clause = ""
    sterile_clause = ""
    put_and = ""
    put_and = "and" if (orphan and sterile)
    
    if orphan
      orphan_clause = "guid not in (select childs_guid from belongs where users_id = '#{user.id}')"
    end
    
    if sterile
      sterile_clause = "guid not in (select parents_guid from belongs where users_id = '#{user.id}')"
    end
    
    return execute("
    with user_dagrs as (
    select guid,dagrs.name as file_name,storage_path,creator_name,
    file_size,dagrs.created_at,dagrs.updated_at,annotations.name as name,keywords,
    file_size as size

    from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
    left join annotations on (annotations.id = user_has.annotations_id)
    where user_has.users_id = '#{user.id}')

    select *
    from user_dagrs
    where #{orphan_clause} #{put_and} #{sterile_clause};")
  end
  
  #find all dagrs reachable by this dagr
  #level = int, up is true if ancestors
  #falase if desendents
  #WARNING this dose not return PG::result, instead it returns a array of PG::rsult[0]
  #this will act very similar to pg:result
  def self.reach_query(user,dagr,level,up)
    guids = reach(user,dagr.guid,level,up,[]) - [dagr.guid]
    results = []
    guids.each do |guid|
      results.push(execute("
      with user_dagrs as (
      select guid,dagrs.name as file_name,storage_path,creator_name,
      file_size,dagrs.created_at,dagrs.updated_at,annotations.name as name,keywords,
      file_size as size

      from dagrs join user_has on (dagrs.guid = user_has.dagrs_guid)
      left join annotations on (annotations.id = user_has.annotations_id)
      where user_has.users_id = '#{user.id}')

      select *
      from user_dagrs
      where guid = '#{guid}';")[0])
    end
    return results
  end
  
  #helper methods for reach_query
  #found = prevously found guids
  def self.reach(user,dagr_guid,level,up,found)
    if level == 0 or found.include?(dagr_guid)
      return []
    end
    guids = []
    result = Belong.find_all_relationships(user,dagr_guid,up)
    result.each do |record|
      next_guid = record["guid"]
      guids.push next_guid
      reach(user,next_guid,level-1,up,found.push(dagr_guid)).each do |g|
        guids.push(g)
      end
    end
    return guids.uniq
  end  
end
    
#Dagr.meta_data_query(User.find(1),"cat","categorys",["a","b","c"],"bob",".txt",266)
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
