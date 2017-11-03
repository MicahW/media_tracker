class UserController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      redirect_to root_path
    else
      render 'new'
    end
  end
  
  def user_params
    params.require(:user).permit(:name, :password)                         
  end
end