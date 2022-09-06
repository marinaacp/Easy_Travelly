class Trip < ApplicationRecord
  include Apitude

  CURRENCY = %w[EUR USD].freeze
  DESTINATIONS = {
    MAD: 'Madri',
    PAR: 'Paris',
    LON: 'London'
  }

  belongs_to :user
  has_one :booking, dependent: :destroy
  has_many :hotels, dependent: :destroy
  has_many :flights, dependent: :destroy
  has_many :activities, dependent: :destroy

  validates :start_date, :location, :destination, :end_date, :adults, :rooms, :budget, presence: true

  validate :end_date_after_start_date

  def budget_error
    errors.add(:budget, message: 'must be higher')
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:start_date, "must be in the future") if start_date <= Date.today

    errors.add(:end_date, "must be after the start date") if end_date < start_date
  end
end
