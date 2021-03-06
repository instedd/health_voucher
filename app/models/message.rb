class Message < ActiveRecord::Base
  extend Enumerize

  enumerize :message_type, in: [:unknown, :authorization, :confirmation], default: :unknown, predicates: true
  enumerize :status, in: [:success, :failure, :error], predicates: true

  has_many :authorizations
  has_one :confirmation_txn, foreign_key: 'message_id', class_name: 'Transaction'

  scope :for_listing, ->{}

  paginates_per 15

  def succeed(response)
    self.status = :success
    self.response = response
  end

  def fail(response)
    self.status = :failure
    self.response = response
  end

  def set_error(response)
    self.status = :error
    self.response = response
  end
end
