class Provider < ActiveRecord::Base
  attr_accessible :code, :enabled, :name

  belongs_to :clinic
end
