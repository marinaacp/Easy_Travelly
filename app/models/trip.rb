class Trip < ApplicationRecord
  belongs_to :user
  has_one :flight
  has_one :hotel

  validates :start_date, :end_date, :location, :budget, presence: true
end
