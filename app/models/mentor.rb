class Mentor < ActiveRecord::Base
  attr_accessible :name

  belongs_to :site

  has_many :patients, :order => [:agep_id]

  validates_presence_of :name, :site
  validates_length_of :name, :maximum => 80

  before_destroy :check_no_patients

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
