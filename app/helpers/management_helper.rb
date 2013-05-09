module ManagementHelper
  def first_unassigned_card_serial_number(site)
    site.unassigned_cards.first.try(:serial_number) 
  end

  def target_mentors_for_select(site, current = nil)
    options_for_select(site.mentors.order(:name).reject do |mentor|
      mentor == current
    end.map do |mentor|
      [mentor.name, mentor.id]
    end)
  end
end
