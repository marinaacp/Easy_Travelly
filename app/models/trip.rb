class Trip < ApplicationRecord
  include Apitude

  has_one :booking
  belongs_to :user
  has_many :hotels
  has_many :flights

  validates :start_date, :destination, :end_date, :adults, :children, :rooms, :budget, presence: true
end
