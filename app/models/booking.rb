class Booking < ApplicationRecord
  belongs_to :trip
  has_one :hotel
  has_one :flight
end
