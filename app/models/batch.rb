class Batch < ActiveRecord::Base
  attr_accessible :name, :initial_serial_number, :quantity

  has_many :cards, :dependent => :destroy

  validates_presence_of :name, :initial_serial_number, :quantity
  validates_length_of :name, :maximum => 150
  validates_format_of :initial_serial_number, :with => /\A[0-9]+\z/
  validates_length_of :initial_serial_number, :is => Card::SERIAL_NUMBER_LENGTH
  validates_numericality_of :quantity, :greater_than => 0, :integer_only => true
  validate :check_overlaps

  def initial_serial_number=(value)
    write_attribute :initial_serial_number, value.to_serial_number
  end

  private

  def check_overlaps
    # FIXME 
  end
end
