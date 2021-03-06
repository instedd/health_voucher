class Site < ActiveRecord::Base
  belongs_to :user
  has_many :clinics, :dependent => :destroy
  has_many :mentors, :dependent => :destroy
  has_many :patients, :through => :mentors
  has_many :cards, :dependent => :nullify
  has_many :providers, :through => :clinics

  scope :non_training, -> { where(:training => [nil, false]) }

  validates_presence_of :name
  validates_length_of :name, :maximum => 100

  def manager
    user
  end

  def unassigned_cards
    cards.where(:patient_id => nil).order(:serial_number)
  end

  def active_cards
    cards.where('cards.patient_id IS NOT NULL').where(:status => :active)
  end

  def self.with_patient_counts
    joins(:patients).group('sites.id').
      select(['sites.*',
              'COUNT(patients.id) AS patient_count',
              'COUNT(CASE WHEN patients.current_card_id IS NULL THEN 1 END) AS patients_without_card'])
  end
end
