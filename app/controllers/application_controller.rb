class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :null_session
  include SessionsHelper
  include ApplicationHelper
  
  @display_removal = false
  @all_checked = false
  
  def logged_in_user
      unless logged_in?
        flash[:danger] = "Please log in."
        redirect_to login_url
        store_location
      end
  end
end
