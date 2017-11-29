class DagrController < ApplicationController
  before_action :logged_in_user, only: [:new, :create_file, :show, :index]
  
  include DagrHelper
  
  def new
  end
  
  def update
    keywords = params[:keywords]
    name = params[:name]
    
    keywords = nil if keywords == ""
    name = nil if name == ""
    
    #if both not nil, and (iether keywords is nil, or it matches the requiernmtns)
    if (keywords or name) and (!keywords or /\A(\w+,)*\w+\z/ =~ keywords)
      Annotation.add_annotation(current_user,Dagr.find(params[:guid]),name,keywords)
    end
    redirect_to dagr_path(params[:guid])
    
  end
  
  def index
    cats = Category.get_all_categories(current_user)
    @categories = []
    
    cats.each do |c|
      @categories.push(Category.find(c["id"]))
    end
    
    @dagrs = Dagr.get_all_dagrs(current_user)
  end
  
  def show
    @all_checked = true
    cats = Category.get_all_categories(current_user)
    @categories = []
    
    cats.each do |c|
      @categories.push(Category.find(c["id"]))
    end
    
    dagr_obj = Dagr.find(params[:guid])
    if !current_user.has_dagr?(dagr_obj)
      redirect_to root_path
    end
    #realy just one dagr
    @dagrs = Dagr.get_dagr_annotations(current_user,dagr_obj)
    @dagr_guid = @dagrs[0]["guid"]
    
    @children = Belong.find_all_relationships(current_user,params[:guid],false)
    @parents = Belong.find_all_relationships(current_user,params[:guid],true)
  end
  
  def alter
    guids = []
    params.each do |k,v|
      guids.push k if v == "checked"
    end
    str = ""
    
    if params[:commit] == "remove children"
      parent = Dagr.find(params[:hidden])
      guids.each do |guid|
        child = Dagr.find(guid)
        Belong.remove_relationship(current_user,parent,child)
      end
    end
    
    if params[:commit] == "remove parents"
      child = Dagr.find(params[:hidden])
      guids.each do |guid|
        parent = Dagr.find(guid)
        Belong.remove_relationship(current_user,parent,child)
      end
    end
    
    if params[:commit] == "add children"
      parent = Dagr.where(guid: params[:parents_guid]).take
      if parent
        guids.each do |guid|
          child = Dagr.find(guid)
          Belong.add_relationship(current_user,parent,child)
        end
      end
    end
    
    if params[:commit] == "add to category" and params[:category_id] 
      category = Category.find(params[:category_id])
      guids.each do |guid|
        dagr = Dagr.find(guid)
        Categorize.add_categorization(category,current_user,dagr)
        str += dagr.name
        str += ", "
      end
      str += "added to #{category.name}"
    elsif params[:commit] == "remove from category"
      guids.each do |guid|
        dagr = Dagr.find(guid)
        Categorize.remove_dagrs_categorization(dagr)
        str += "#{dagr.name}, "
      end
      str += "removed from categorys"
    elsif params[:commit] == "delete dagr!"
      guids.each do |guid|
        dagr = Dagr.find(guid)
        dagr.remove_dagr(current_user)
        str += "#{dagr.name}, "
      end
      flash[:danger] = str
      redirect_to all_dagrs_path
      return
      
    #this is the delete specified in the project decription
    elsif params[:commit] == "full delete!"
      if guids.size != 1
        flash[:danger] = "Must Chose exactly one Dagr for Full delete"
      else
        @dagr_guid = guids[0]
        @parents = Belong.find_all_relationships(current_user,@dagr_guid,true)
        render 'delete_parents'
        return
      end
    end
    flash[:danger] = str
    redirect_back(fallback_location: all_dagrs_path)
  end
  
  def delete_parents
    puts params[:hidden]
    @dagr_guid = params[:guid]
    @delete_parents = params[:commit]
    @children = Belong.find_all_relationships(current_user,@dagr_guid,false)
    
    render 'delete_children'
  end
  
  def delete_children
    dagr = Dagr.find params[:guid]
    delete_parents = params[:delete_parents]
    
    dagr.delete_parents(current_user) if delete_parents == "Yes"
    
    if params[:commit] == "Shallow"
      dagr.child_delete_dagr(current_user)
    elsif params[:commit] == "Deep"
      dagr.rec_delete_dagr(current_user)
    end
    redirect_to all_dagrs_path
  end
  
  #bulk insert from java client
  def bulk_insert
    user = User.find_by(name: params[:user])
    if user && user.authenticate(params[:password])  
      data = JSON.parse(params[:data])
      data.each do |el|
       if el["name"] =~ /\./
        Dagr.add_dagr(user,el["name"], el["path"],el["size"], el["name"].split(".")[0], nil) 
        puts el
       end
      end
    else 
      render json: {}, status: 401
      return
    end
  end
  
  #create file from bulk entry
  def create_files
    path = params[:path]
    
    if (path != "")
      data = JSON.parse(params[:post])
      data.each do |el|
        Dagr.add_dagr(current_user,el["name"], path,el["size"], el["name"].split(".")[0], nil)
      end
      flash[:danger] = "Dagrs added"
    else
      flash[:danger] = "path must be filled out"
    end
    render 'new'
  end
  
  
  def create_file
    #if not all values filled out properly
    if (params[:file_name] == "" or !(/\A[\w\- ]+(\.\w{1,})+\z/ =~ params[:file_name]) or
        params[:storage_path] == "" or params[:file_size] == "" or !(/\A\d*\z/ =~ params[:file_size]) or
      (params[:keywords] != "" and !(/\A(\w+,)*\w+\z/ =~ params[:keywords])))
      flash[:danger] = "ERROR INVLAID, see above requirnments"
      render 'new'
    else
      
      #valid file or url
      name = params[:name]
      keywords = params[:keyword]
      name = nil if name == ""
      keywords = nil if keywords == ""
      
      user = current_user
      dagr = Dagr.add_dagr(user,params[:file_name], params[:storage_path],
          params[:file_size], name,keywords)
      #if dagr == nil
        #flash[:danger] = "already have dagr"
        #render 'new'
      #else
        flash_str = "#{dagr.name} added. "
      
        #if this is a html document
        if params[:file_name] =~ /\.html\z/ and params[:storage_path] =~ /\Ahttp/
          flash_str += parse_html(user,dagr)
          flash_str += " added"
        end
        flash[:danger] = flash_str
        render 'new'
      #end
    end 
  end     
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
