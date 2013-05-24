class Date
  HUMAN_PARAM_FORMAT = '%m/%d/%Y'
  HUMAN_DISPLAY_FORMAT = 'mm/dd/yyyy'

  # Parse a string parameter (from the user) as a Date
  def self.parse_human_param(value)
    Date.strptime(value, HUMAN_PARAM_FORMAT)
  end

  def to_human_param
    strftime(HUMAN_PARAM_FORMAT)
  end
end
