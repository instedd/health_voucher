class Patient < ActiveRecord::Base
  AGEP_ID_REGEX = /\A ( \d{7} | \d{10} | \d{9} )\z/x
  attr_accessible :agep_id

  belongs_to :mentor
  has_one :site, :through => :mentor

  has_many :cards
  belongs_to :current_card, :class_name => 'Card'

  scope :with_card, where('current_card_id IS NOT NULL')
  scope :without_card, where(:current_card_id => nil)

  validates_presence_of :agep_id, :mentor
  validates_format_of :agep_id, :with => AGEP_ID_REGEX
  validates_uniqueness_of :agep_id

  validate :check_current_card
  after_save :assign_current_card
  before_destroy :check_no_cards

  def deactivate_card!(reason=nil)
    if current_card
      transaction do
        if reason == :lost
          current_card.report_lost!
        else
          current_card.deactivate!
        end
        self.current_card = nil
        save!
      end
    end
  end

  def unassign_card!
    if can_unassign?
      transaction do
        current_card.patient = nil
        current_card.validity = nil unless current_card.used?
        current_card.save!
        self.current_card = nil
        save!
      end
    end
  end

  def self.valid_agep_id?(agep_id)
    agep_id =~ AGEP_ID_REGEX
  end

  def can_be_destroyed?
    cards.empty?
  end

  def can_unassign?
    current_card.present? && (!current_card.used? || !current_card.active?)
  end

  private

  def check_current_card
    if current_card
      unless current_card.patient == self || current_card.patient.nil?
        errors[:current_card] << "belongs to another patient"
      end
    end
  end

  def assign_current_card
    current_card.update_attribute :patient, self unless current_card.nil?
    true
  end

  def check_no_cards
    if cards.count > 0
      errors[:base] << "The patient has (or has had) cards assigned"
      false
    else
      true
    end
  end
end
