class Trip < ApplicationRecord
  has_one :booking
  belongs_to :user
  has_many :hotels

  geocoded_by :destination
  after_validation :geocode, if: :will_save_change_to_destination?

  validates :start_date,:destination, :end_date, :travellers, :budget, presence: true
end
