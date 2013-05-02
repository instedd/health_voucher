class Batch < ActiveRecord::Base
  attr_accessible :name, :initial_serial_number, :quantity

  has_many :cards, :dependent => :destroy

  validates_presence_of :name, :initial_serial_number, :quantity
  validates_length_of :name, :maximum => 150
  validates_format_of :initial_serial_number, :with => /\A[0-9]+\z/
  validates_length_of :initial_serial_number, :is => Card::SERIAL_NUMBER_LENGTH
  validates_numericality_of :quantity, :greater_than => 0, :integer_only => true
  validate :check_overlaps
  validate :forbid_changes_after_cards_created

  def initial_serial_number=(value)
    write_attribute :initial_serial_number, value.to_serial_number
  end

  def first_serial_number
    initial_serial_number.to_i 
  end

  def last_serial_number
    initial_serial_number.to_i + quantity - 1
  end

  def cards_with_vouchers
    cards.includes(:vouchers)
  end

  private

  def check_overlaps
    from = initial_serial_number.to_i
    to = from + quantity - 1
    overlaps = Batch.all.reject { |batch| batch == self }.any? do |batch|
      (from >= batch.first_serial_number && from <= batch.last_serial_number) ||
      (to >= batch.first_serial_number && to <= batch.last_serial_number) ||
      (batch.first_serial_number >= from && batch.last_serial_number <= to)
    end
    if overlaps
      errors[:base] << "overlaps with another batch"
    end
  end

  def forbid_changes_after_cards_created
    return if cards.count == 0
    [:initial_serial_number, :quantity].each do |attr|
      if changes.include?(attr)
        errors[attr] << "can not be changed after cards have been created" 
      end
    end
  end
end
