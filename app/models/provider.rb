class Provider < ActiveRecord::Base
  belongs_to :clinic
  attr_accessible :code, :enabled, :name
end
