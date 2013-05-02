class Card < ActiveRecord::Base
  extend Enumerize

  SERIAL_NUMBER_LENGTH = 6
  PRIMARY_SERVICES = 6
  SECONDARY_SERVICES = 7

  attr_accessible :serial_number

  has_many :vouchers, :dependent => :destroy

  belongs_to :pacient
  belongs_to :site
  belongs_to :batch

  enumerize :status, in: [:active, :lost, :depleted, :expired], default: :active, predicates: true

  validates_presence_of :batch, :serial_number
  validates_uniqueness_of :serial_number
  validates_format_of :serial_number, :with => /\A[0-9]+\z/
  validates_length_of :serial_number, :is => SERIAL_NUMBER_LENGTH
  validate :valid_check_digit

  def full_serial_number
    "#{check_digit}#{serial_number}"
  end

  def serial_number=(value)
    value = value.to_serial_number
    write_attribute :serial_number, value
    write_attribute :check_digit, Card::Damm.generate(value)
  end

  private

  def valid_check_digit
    unless check_digit == Card::Damm.generate(serial_number)
      errors[:check_digit] << "is invalid"
    end
  end
end
