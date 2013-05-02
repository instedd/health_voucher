class Batch < ActiveRecord::Base
  attr_accessible :name, :intial_serial_number, :quantity

  has_many :cards

  validates_presence_of :name, :initial_serial_number, :quantity
  validates_length_of :name, :maximum => 150
  validates_format_of :initial_serial_number, :with => /\A[0-9]+\z/
  validates_length_of :initial_serial_number, :is => Card::SERIAL_NUMBER_LENGTH
  validates_numericality_of :quantity, :greater_than => 0, :integer_only => true
end
