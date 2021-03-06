class UsersController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs
  before_filter :load_user, only: [:edit, :update, :destroy]

  def index
    @users = User.for_listing
  end

  def new
    add_breadcrumb 'New user', new_user_path
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_activity @user, "#{@user.email} created with role #{@user.role.text}"
      redirect_to users_path, notice: 'User created'
    else
      add_breadcrumb 'New user', new_user_path
      render :new
    end
  end

  def edit
    add_breadcrumb @user.email, edit_user_path(@user)
  end

  def update
    params[:user].delete(:role) if @user == current_user

    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    @user.update_attributes user_params
    if @user.save
      if !@user.site_manager? && @user.site
        @user.site.update_attribute :user_id, nil
      end

      message = "#{@user.email} updated, #{@user.role.text} role given"
      if params[:user][:password].present?
        message << ", password changed"
      end
      log_activity @user, message

      redirect_to users_path, notice: 'User updated'
    else
      add_breadcrumb @user.email, edit_user_path(@user)
      render :edit
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: 'You cannot delete yourself'
    else
      @user.destroy
      log_activity @user, "#{@user.email} deleted"
      redirect_to users_path, notice: 'User deleted'
    end
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Users', users_path
  end

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
