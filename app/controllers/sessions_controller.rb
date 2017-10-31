class SessionsController < ApplicationController
  
  def new
  end

  def create
    user = User.find_by(name: params[:session][:name])
    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to root_path
    else
      flash[:danger] = "invalid"
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
