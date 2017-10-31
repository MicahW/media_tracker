class Annotation < ApplicationRecord
  validate :has_one_value
  
  def has_one_value
    if !name && !keywords
      errors.add(:name, :invalid)
    end
  end
  
  #adds a new annotation or modifies the old one
  #by replacing non nil paramenters with thier atributes
  def self.add_annotation(user,dagr,name,keywords)
    return false if !user.has_dagr?(dagr)
    has = UserHas.where(users_id: user.id, dagrs_guid: dagr.guid).take
    #not existing annotation add this one
    if has.annotations_id == nil
      annotation = Annotation.create(name: name, keywords: keywords)
      UserHas.update(has.id,annotations_id: annotation.id)
      return annotation
    else
      #existing annotation
      annotation = Annotation.find(has.annotations_id)
      
      name ||= annotation.name
      keywords ||= annotation.keywords
      
      return Annotation.update(annotation.id,name: name, keywords: keywords)
    end
  end
  
  #removes annotation from user and dagr realtionship
  #userhas set to null
  def self.remove_annotation(user,dagr)
    return false if !user.has_dagr?(dagr)
    has = UserHas.where(users_id: user.id, dagrs_guid: dagr.guid).take
    UserHas.update(has.id,annotations_id: nil)
    Annotation.destroy(has.annotations_id) if has.annotations_id
  end
 
      
end
