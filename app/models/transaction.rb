class Transaction < ActiveRecord::Base
  belongs_to :provider
  belongs_to :voucher
  belongs_to :service
  belongs_to :authorization
  attr_accessible :comment, :status
end
