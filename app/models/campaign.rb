class Campaign < ApplicationRecord
  include UuidConcern

  enum campaign_type: {
    live_competition: 0,
    training_camp: 1
  }

  has_rich_text :content

  has_one_attached :desktop_banner
  has_one_attached :mobile_banner

  before_create :set_uuid

  has_one :lead_form

  scope :without_lead_form, -> { includes(:lead_form).where(lead_forms: { id: nil }) }

  def set_uuid
    self.uuid = SecureRandom.base58(12)
  end
end
