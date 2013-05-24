class Statement::GenerateForm
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def persisted?
    false
  end

  ATTRIBUTES = [:site_id, :clinic_id, :until]

  attr_accessor *ATTRIBUTES

  validates_presence_of :site_id, :until

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
    @until ||= Time.now
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

  def site
    @site ||= Site.find(@site_id)
  end

  def clinic
    @clinic ||= Clinic.find(@clinic_id) if @clinic_id.present?
  end

  validate do
    if site_id.present? && site.training?
      errors[:site_id] << "is a training site"
    end
  end

  def generate
    if clinic.nil?
      Statement.transaction do
        site.clinics.map do |clinic|
          generate_one(clinic)
        end
      end
    else
      [generate_one(clinic)]
    end.reject do |stmt|
      stmt.nil?
    end
  end

  private

  def generate_one(clinic)
    Statement::Generator.new(clinic, @until).generate
  end
end

