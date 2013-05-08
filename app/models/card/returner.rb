class Card::Returner
  def return_cards(ids)
    Card.transaction do
      cards = Card.where("patient_id IS NULL").where("id IN (?)", ids)
      cards.each do |card|
        card.update_attribute :site_id, nil
      end
      cards
    end
  end
end

