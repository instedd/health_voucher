class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # :registerable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_one :user

  def update_for_site_manager(params)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    update_attributes params
    clean_up_passwords
  end
end
