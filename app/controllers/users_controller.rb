class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_with_password(params[:user])
      redirect_to root_path, notice: "Settings saved"
    else
      render 'edit'
    end
  end
end

