class Authorization < ActiveRecord::Base
  attr_accessible :card, :provider, :service, :message

  belongs_to :card
  belongs_to :provider
  belongs_to :service
  belongs_to :message
  has_one :transaction

  validates_presence_of :card, :provider, :service

  scope :today, lambda {
    where("authorizations.created_at >= ?", Time.zone.now.beginning_of_day).
      where("authorizations.created_at <= ?", Time.zone.now)
  }

  scope :by_card, lambda { |card| where(:card_id => card.id) }

  scope :by_clinic, lambda { |clinic| 
    joins(:provider).where('providers.clinic_id = ?', clinic.id) 
  }

  scope :confirmed, joins(:transaction)
  scope :pending, joins('LEFT JOIN transactions ON transactions.authorization_id = authorizations.id').where('transactions.id IS NULL')

  def training?
    card.site.try(:training?) || provider.site.try(:training?)
  end

  def clinic_service
    provider.clinic.clinic_services.where(:service_id => service_id).first
  end
end
