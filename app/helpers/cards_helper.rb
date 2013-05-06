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
end
