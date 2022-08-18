class Trip < ApplicationRecord
  include Apitude

  has_one :booking
  belongs_to :user
  has_many :hotels
  has_many :flights

  validates :start_date, :destination, :end_date, :adults, :children, :rooms, :budget, presence: true

  validate :end_date_after_start_date

  def budget_error
    errors.add(:budget, message: 'must be higher')
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if start_date <= Date.today
      errors.add(:start_date, "must be in the future")
    end

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
