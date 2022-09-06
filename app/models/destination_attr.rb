class DestinationAttr < ApplicationRecord
  d = {}
  DestinationAttr.all.each do |destination|
    destination_complete = "#{destination.city_name}, #{destination.country_name}"
    d[destination_complete] = destination.city_code
  end

  DESTINATION = d
  # (.freeze)
end
