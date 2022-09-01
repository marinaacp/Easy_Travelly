class Destination < ApplicationRecord
  belongs_to :country

  d = {}
  Destination.all.each do |destination|
    destination_complete = "#{destination.name}, #{destination.country.name}"
    d[destination_complete] = destination.code
  end

  DESTINATION = d.freeze

  validates :code, uniqueness: true
end
