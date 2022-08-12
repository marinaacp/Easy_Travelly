class Trip < ApplicationRecord
  belongs_to :user
  validates :location, :start_date, :end_date, :budget, presence: true
end
