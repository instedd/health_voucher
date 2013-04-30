class Batch < ActiveRecord::Base
  attr_accessible :intial_serial_number, :name, :quantity

  has_many :cards
end
