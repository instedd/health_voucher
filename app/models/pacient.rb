class Pacient < ActiveRecord::Base
  attr_accessible :agep_id

  belongs_to :mentor

  has_many :cards
  belongs_to :current_card, :class_name => 'Card'

  validates_presence_of :agep_id
  validates_format_of :agep_id, :with => /\A([0-9]{7}|[0-9]{10})\z/

  validate :check_current_card
  after_save :assign_current_card

  private

  def check_current_card
    if current_card
      unless current_card.pacient == self || current_card.pacient.nil?
        errors[:current_card] << "belongs to another pacient"
      end
    end
  end

  def assign_current_card
    current_card.update_attribute :pacient, self unless current_card.nil?
    true
  end
end
