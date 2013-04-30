class Service < ActiveRecord::Base
  attr_accessible :code, :description, :service_type, :short_description
end
