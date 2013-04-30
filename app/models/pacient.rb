class Pacient < ActiveRecord::Base
  belongs_to :mentor
  attr_accessible :agep_id
end
