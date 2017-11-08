class DagrController < ApplicationController
  before_action :logged_in_user, only: [:new, :create_file, :show, :index]
  
  include DagrHelper
  
  def new
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
    
    @children = Belong.find_all_relationships(current_user,params[:guid],false)
    puts @children.values
  end
  
  def alter
    guids = []
    params.each do |k,v|
      guids.push k if v == "checked"
    end
    str = ""
    
    if params[:commit] == "add to category" and 
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
    end
    
    flash[:danger] = str
    redirect_back(fallback_location: root_path)
    
    
  end
  
  def create_file
    #if not all values filled out properly
    if (params[:file_name] == "" or !(/\A\w*(\.\w{2,})+\z/ =~ params[:file_name]) or
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
