module CardsHelper
  def cards_availability(batches)
    batches.inject({}) do |result, batch|
      result[batch.id] = { 
        first_serial_number: batch.cards_available.first.try(:serial_number),
        quantity: batch.cards_available.count
      }
      result
    end
  end

  def card_serial_number(card)
    if card
      "#{card.check_digit}-#{card.serial_number}"
    else
      ''
    end
  end

  def card_validity(card)
    if card && card.validity
      card.validity.to_time.to_s(:date)
    else
      ''
    end
  end
end
