class Mentor < ActiveRecord::Base
  belongs_to :site

  has_many :patients

  validates_presence_of :name, :site
  validates_length_of :name, :maximum => 80

  before_destroy :check_no_patients

  def self.with_patient_counts
    scoped.joins(:patients, :site).group('mentors.id').
      select(['mentors.*', 'sites.name AS site_name', 
              'COUNT(patients.id) AS patient_count', 
              'COUNT(CASE WHEN patients.current_card_id IS NULL THEN 1 END) AS patients_without_card'])
  end

  private

  def check_no_patients
    if patients.count > 0
      errors[:base] << "Mentor has patients"
      false
    else
      true
    end
  end
end
