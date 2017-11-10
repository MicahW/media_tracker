class QueryController < ApplicationController
  before_action :logged_in_user
  def new
    @dagrs = nil
  end
  
  def generate
    @dagrs = nil
    
    if params[:commit] == "Time Range Query"
      start_time = params[:start]
      end_time = params[:end]
      
      created = true
      created = false if !params[:find_created]
      
      if /\d{4}\-\d{1,2}\-\d{1,2} \d{1,2}\:\d{2}\:\d{2}/ =~ start_time and
         /\d{4}\-\d{1,2}\-\d{1,2} \d{1,2}\:\d{2}\:\d{2}/ =~ end_time
        @dagrs = Dagr.time_range_query(current_user,start_time,end_time,created)
      end
    end
    
    if params[:commit] == "Orphan Sterile Query"
      orphan = true
      sterile = true
      
      orphan = false if !params[:find_orphans]
      sterile = false if !params[:find_sterile]
      
      if(orphan or sterile)
        @dagrs = Dagr.orphan_sterile_query(current_user,orphan,sterile)
      end
    end
    
    if params[:commit] == "Meta Data Query"
      #in form [name,file_name,storage_path,keywords,author,type,size,all_keywords]
      query = []
      query.push(params[:name]) 
      query.push(params[:file_name])
      query.push(params[:storage_path])
      query.push(params[:keywords])
      query.push(params[:author])
      query.push(params[:file_type])
      query.push(params[:file_size])
      
      (0..query.length).each do |i|
        query[i] = nil if query[i] == ""
        if query[i] 
          puts query[i]
        else
          puts "nil"
        end
      end
      if query[3]
        query[3] = query[3].split(",")
      else
        query[3] = nil
      end
      
      
      all_keywords = true
      all_keywords = false if !params[:all_keywords]
      
      @dagrs = Dagr.meta_data_query(
        current_user,query[0],query[1],query[2],query[3],query[4],query[5],query[6],all_keywords)
      
      
    end
    cats = Category.get_all_categories(current_user)
    @categories = []
    
    cats.each do |c|
      @categories.push(Category.find(c["id"]))
    end
    
    render 'new'
  end
end
