class Service < ActiveRecord::Base
  extend Enumerize

  attr_accessible :code, :description, :service_type, :short_description

  enumerize :service_type, in: [:primary, :secondary], predicates: true

  validates_presence_of :code, :description, :service_type, :short_description
  validates_format_of :code, :with => /\A[1-9][0-9]\z/
  validates_uniqueness_of :code
  validates_length_of :description, :maximum => 100
  validates_length_of :short_description, :maximum => 30
end
