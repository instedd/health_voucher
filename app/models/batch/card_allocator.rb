class Batch::CardAllocator
  def initialize(batch)
    @batch = batch
  end

  def assign_to_site(site, first, quantity = 1)
    available = @batch.cards_available.where("serial_number >= ?", first)
    return nil if available.count < quantity

    cards = available.take(quantity)
    Card.transaction do
      cards.each do |card|
        card.update_attribute :site_id, site.id
      end
    end
  end
end
