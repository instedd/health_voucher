class Message < ActiveRecord::Base
  extend Enumerize

  validates_presence_of :body

  enumerize :type, in: [:unknown, :authorization, :confirmation], default: :unknown, predicates: true
  enumerize :status, in: [:success, :failure], predicates: true

  attr_accessible :from, :body
end

