class Card < ActiveRecord::Base
  extend Enumerize

  SERIAL_NUMBER_LENGTH = 6
  PRIMARY_SERVICES = 6
  SECONDARY_SERVICES = 7
  ANY_SERVICES = 12

  DEFAULT_VALIDITY = 1.year

  attr_accessible :serial_number

  has_many :vouchers, :dependent => :destroy
  has_many :authorizations
  has_many :used_vouchers, ->{ where used: true }, :class_name => "Voucher"
  has_many :unused_vouchers, ->{ where used: false }, :class_name => "Voucher"

  belongs_to :patient
  belongs_to :site
  belongs_to :batch

  enumerize :status, in: [:active, :lost, :inactive], default: :active, predicates: true

  validates_presence_of :batch, :serial_number
  validates_uniqueness_of :serial_number
  validates_format_of :serial_number, :with => /\A[0-9]+\z/
  validates_length_of :serial_number, :is => SERIAL_NUMBER_LENGTH
  validate :valid_check_digit
  validate :validity_check

  before_save :set_expiration_from_validity

  def self.valid_serial_number?(sn)
    sn.length == SERIAL_NUMBER_LENGTH + 1 &&
      Card::Damm.generate(sn[1..-1]) == sn[0]
  end

  def self.find_by_serial_number(sn)
    if sn.to_s.length == SERIAL_NUMBER_LENGTH + 1
      self.where(serial_number: sn.to_s[1..-1], check_digit: sn.to_s[0]).first
    else
      self.where(serial_number: sn).first
    end
  end

  def full_serial_number
    "#{check_digit}#{serial_number}"
  end

  def serial_number=(value)
    value = value.to_serial_number
    write_attribute :serial_number, value
    write_attribute :check_digit, Card::Damm.generate(value)
  end

  def primary_services
    vouchers.select { |v| v.primary? }
  end

  def secondary_services
    vouchers.select { |v| v.secondary? }
  end

  def any_services
    vouchers.select { |v| v.any? }
  end

  def expired?
    expiration.present? && expiration.past?
  end

  def depleted?
    !unused_vouchers.any?
  end

  def report_lost!
    update_attribute :status, :lost
  end

  def deactivate!
    update_attribute :status, :inactive
  end

  def unused_vouchers(type = nil)
    if type.nil?
      vouchers.where(:used => false)
    else
      vouchers.where(:used => false).where(:service_type => type)
    end
  end

  def used?
    used_vouchers.any? || authorizations.any?
  end

  def validated?
    validity.present?
  end

  def validity=(value)
    begin
      if value.nil?
        new_value = nil
      elsif value.is_a?(String)
        new_value = Date.parse_human_param(value) rescue Date.parse(value)
      elsif value.is_a?(Date) or value.is_a?(Time)
        new_value = value
      else
        raise ArgumentError, "invalid date value"
      end
      @invalid_date = false
      write_attribute :validity, new_value
    rescue
      @invalid_date = true
      write_attribute :validity, nil
    end
  end

  def expiration=(value)
    begin
      if value.nil?
        new_value = nil
      elsif value.is_a?(String)
        new_value = Date.parse_human_param(value) rescue Date.parse(value)
      elsif value.is_a?(Date) or value.is_a?(Time)
        new_value = value
      else
        raise ArgumentError, "invalid date value"
      end
      @invalid_expiration = false
      write_attribute :expiration, new_value
    rescue
      @invalid_expiration = true
    end
  end

  private

  def valid_check_digit
    unless check_digit == Card::Damm.generate(serial_number)
      errors[:check_digit] << "is invalid"
    end
  end

  def validity_check
    if @invalid_date
      errors[:validity] << "is invalid"
    elsif validity.present?
      if validity.future?
        errors[:validity] << "cannot be in the future"
      elsif validity.to_date < created_at.to_date
        errors[:validity] << "cannot be before the card was created"
      elsif expiration.present? && validity > expiration
        errors[:validity] << "cannot be after the expiration date"
      end
    end
  end

  def expiration_check
    if @invalid_expiration
      errors[:expiration] << "is invalid"
    elsif expiration.present?
      if expiration < validity
        errors[:expiration] << "cannot be before validity"
      end
    end
  end

  def set_expiration_from_validity
    if validity.present?
      self.expiration = validity + DEFAULT_VALIDITY if expiration.nil?
    else
      self.expiration = nil
    end
  end
end
