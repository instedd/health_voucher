class Statement::GenerateForm
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def persisted?
    false
  end

  ATTRIBUTES = [:clinic_id, :until]

  attr_accessor *ATTRIBUTES

  validates_presence_of :clinic_id, :until

  validate do
    if clinic_id.present? && clinics.any? { |clinic| clinic.site.training? }
      errors[:clinic_id] << "is from a training site"
    end
  end

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
    @until ||= Date.today
  end

  def clinic_id=(value)
    value = value.reject(&:blank?) if value.is_a?(Array)
    @clinic_id = value
  end

  def until=(value)
    @until = Date.parse_human_param(value) rescue nil
  end

  def until(format = nil)
    if format == :date || @until.nil?
      @until
    else
      @until.to_date.to_human_param
    end
  end

  def clinics
    @clinics ||= Clinic.find(@clinic_id) if @clinic_id.present?
  end

  def generate
    Statement.transaction do
      clinics.map do |clinic|
        generate_one(clinic)
      end
    end.reject do |stmt|
      stmt.nil?
    end
  end

  private

  def generate_one(clinic)
    Statement::Generator.new(clinic, @until).generate
  end
end

