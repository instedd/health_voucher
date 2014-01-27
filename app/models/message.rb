class Message < ActiveRecord::Base
  extend Enumerize

  validates_presence_of :body

  enumerize :message_type, in: [:unknown, :authorization, :confirmation], default: :unknown, predicates: true
  enumerize :status, in: [:success, :failure, :error], predicates: true

  attr_accessible :from, :body

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

