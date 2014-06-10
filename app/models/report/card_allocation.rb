class Report::CardAllocation < Report
  attr_reader :site_id

  group_by :site, :mentor

  def self.build params
    new(params).build
  end

  def initialize(params)
    super

    @site_id = params[:site_id]
  end

  def build
    patients_with_uses = Patient.joins(:current_card => {:authorizations => :transaction}, :mentor => []).uniq
    patients_with_uses = add_date_criteria(patients_with_uses, 'transactions.created_at')

    if by_mentor?
      patients_with_uses = patients_with_uses.select(['patients.id', 'mentors.id AS grouping_id'])
      groupings = Mentor.with_patient_counts.order(:name)
      if site_id.present?
        groupings = groupings.where(:site_id => site_id)
      end
    else
      patients_with_uses = patients_with_uses.select(['patients.id', 'mentors.site_id AS grouping_id'])
      groupings = Site.with_patient_counts.order(:name)
    end
    grouping_for_uses = patients_with_uses.map(&:grouping_id)

    @data = groupings.map do |group|
      {
        :name => group.name,
        :site_name => group['site_name'],
        :patient_count => group.patient_count,
        :patients_with_card => group.patient_count - group.patients_without_card,
        :patients_without_card => group.patients_without_card,
        :patients_with_recent_card_uses => grouping_for_uses.count { |id| id == group.id }
      }
    end
    @totals = totalize @data, [
      :patient_count,
      :patients_with_card,
      :patients_without_card,
      :patients_with_recent_card_uses
    ]
    self
  end
end

