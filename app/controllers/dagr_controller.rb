class DagrController < ApplicationController
  before_action :logged_in_user, only: [:new, :create_file, :show]
  
  include DagrHelper
  
  def new
  end
  
  def index
    @dagrs = Dagr.get_all_dagrs(current_user)
  end
  
  def show
    dagr_obj = Dagr.find(params[:guid])
    if !current_user.has_dagr?(dagr_obj)
      redirect_to root_path
    end
    @dagr = Dagr.get_dagr_annotations(current_user,dagr_obj)[0]
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
