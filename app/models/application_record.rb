class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  #pain to type this out so now just execute()
  def self.execute(str)
    ActiveRecord::Base.connection.execute(str)
  end
  def execute(str)
    ActiveRecord::Base.connection.execute(str)
  end
  
  
end
