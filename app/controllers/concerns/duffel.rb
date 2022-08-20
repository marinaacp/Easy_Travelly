require "duffel_api"
require "bigdecimal"

module Duffel
  def search_flights(trip)
    client = DuffelAPI::Client.new(
      access_token: ENV.fetch("DUFFEL_ACCESS_TOKEN"),
    )

    offer_request = client.offer_requests.create(params: {
      cabin_class: "economy",
      passengers: [{
        age: 28,
      }],
      slices: [{
        # We use a non-sensical route to make sure we get speedy, reliable Duffel Airways
        # resullts.
        origin: trip.location,
        destination: trip.destination,
        departure_date: trip.start_date.strftime("%Y-%m-%d"),
      }],
      # This attribute is sent as a query parameter rather than in the body like the others.
      # Worry not! The library handles this complexity for you.
      return_offers: false,
    })

    client.offers.all(params: { offer_request_id: offer_request.id })
  end
end
