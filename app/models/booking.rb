class Booking < ApplicationRecord
  belongs_to :trip
  belongs_to :hotel
  belongs_to :flight
end
