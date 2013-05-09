module ManagementHelper
  def first_unassigned_card_serial_number(site)
    site.unassigned_cards.first.try(:serial_number) 
  end
end
