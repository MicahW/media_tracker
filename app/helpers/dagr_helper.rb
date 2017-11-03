module DagrHelper
  require 'nokogiri'
  require 'open-uri'
  
  #find all src and href atributes in this html document
  #and add them as dagrs that belong to parent dagr
  #returns a list of filenames added
  def parse_html(user,parent_dagr)
    url = ""
    url += parent_dagr.storage_path + "/" + parent_dagr.name
    puts url
    page = Nokogiri::HTML(open(url))
    
    return_string = ""
    #add all video and adeo files
    page.css("source").each do |element|
      file_name = element["src"]
      file_name = add_element(user,parent_dagr,file_name,parent_dagr.storage_path)
      return_string += file_name + ", "
    end
    
    #add all images
    page.css("img").each do |element|
      file_name = element["src"]
      file_name = add_element(user,parent_dagr,file_name,parent_dagr.storage_path)
      return_string += file_name + ", "
    end
    
    #add all javascript
    page.css("script").each do |element|
      file_name = element["src"]
      if file_name
        file_name = add_element(user,parent_dagr,file_name,parent_dagr.storage_path)
        return_string += file_name + ", "
      end
    end
    
    #add all html documents
    page.css("a").each do |element|
      url = element["href"]
      # if url pointed to html document
      if /.html\z/ =~ url       
        file_name =  add_element(user,parent_dagr,url,parent_dagr.storage_path)
        return_string += file_name + ", " 
      end
    end
    
    return return_string
  end
  
  #add this file as a child of the parent dagr
  def add_element(user,parent_dagr,file_path,path)
    file_name = /([\w\-]*\.\w*)/.match(file_path)[0]
        
    path_prefix = /(([\w\-]+\/)*)/.match(file_path)
    if path_prefix.length != 0
      path += "/" + path_prefix[0]
      puts path
    end
     
    puts path
    
    parts = file_name.split(".")
      
    dagr = Dagr.add_dagr(user,file_name,path,0,parts[0],parts[1])
    dagr.add_parent(user,parent_dagr)
    return file_name
  end
end

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    