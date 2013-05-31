class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # :registerable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :email, :password, :password_confirmation, :admin, :as => :admin

  has_one :user
  has_one :site, :dependent => :nullify
  has_many :activities, :dependent => :nullify

  scope :for_listing, order(:email)
  scope :non_admins, where(:admin => false)
  scope :possible_managers, where(:admin => false).joins('LEFT JOIN sites ON users.id = sites.user_id').where('sites.id IS NULL')

  def update_for_site_manager(params)
    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    update_attributes params
  end

  def log_activity(object, description)
    activities.create! object_class: object.class.name, object_id: object.id, description: description
  end
end
