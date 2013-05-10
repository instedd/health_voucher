class Authorization < ActiveRecord::Base
  belongs_to :card
  belongs_to :provider
  belongs_to :service

  scope :today, lambda {
    now = Time.now
    where("created_at >= ?", now.beginning_of_day).
      where("created_at <= ?", now)
  }

  def self.by_card(card)
    where(:card_id => card.id)
  end
end
