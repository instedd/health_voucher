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

  def card_status(card)
    if card
      if card.expired?
        content_tag(:span, '', :class => 'i18o-alert expired', :title => 'Card expired')
      elsif card.depleted?
        content_tag(:span, '', :class => 'i18g-alert depleted', :title => 'Card depleted')
      else
        ''
      end
    else
      ''
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
      card.validity.to_time_in_current_zone.to_s(:date)
    else
      ''
    end
  end

  def card_expiration(card)
    if card && card.expiration
      card.expiration.to_time_in_current_zone.to_s(:date)
    else
      ''
    end
  end
end
