class Authorization < ActiveRecord::Base
  belongs_to :card
  belongs_to :provider
  belongs_to :service
end
