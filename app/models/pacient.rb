class Pacient < ActiveRecord::Base
  attr_accessible :agep_id

  belongs_to :mentor

  has_many :cards
end
