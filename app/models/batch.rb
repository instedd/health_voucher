class Batch < ActiveRecord::Base
  DEFAULT_QUANTITY = 100

  attr_accessible :name, :initial_serial_number, :quantity

  has_many :cards, :dependent => :destroy

  validates_presence_of :name
  validates_length_of :name, :maximum => 150
  validates_format_of :initial_serial_number, :with => /\A[0-9]{#{Card::SERIAL_NUMBER_LENGTH}}\z/
  validates_numericality_of :quantity, :greater_than => 0, :integer_only => true
  validate :check_overlaps
  validate :forbid_changes_after_cards_created

  paginates_per 15

  def self.have_unassigned_cards
    Card.where('site_id IS NULL').select('DISTINCT(batch_id)').map(&:batch)
  end

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

  def cards_available
    cards.where('site_id IS NULL').order('serial_number')
  end

  def cards_in_sites
    cards.where('site_id IS NOT NULL')
  end

  def self.next_serial_number
    Batch.order('initial_serial_number DESC').first.last_serial_number + 1 rescue 1
  end

  def generating?
    cards.count < quantity
  end

  private

  def check_overlaps
    from = first_serial_number rescue nil
    to = last_serial_number rescue nil
    return if from.nil? || to.nil?

    overlaps = Batch.all.reject { |batch| batch == self }.any? do |batch|
      (from >= batch.first_serial_number && from <= batch.last_serial_number) ||
      (to >= batch.first_serial_number && to <= batch.last_serial_number) ||
      (batch.first_serial_number >= from && batch.last_serial_number <= to)
    end
    if overlaps
      errors[:base] << "Overlaps with another batch"
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
