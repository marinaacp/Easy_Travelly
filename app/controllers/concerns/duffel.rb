require "duffel_api"
require "bigdecimal"
require "json"

module Duffel
  def search_flights(trip)
    client = DuffelAPI::Client.new(
      access_token: ENV.fetch("DUFFEL_ACCESS_TOKEN")
    )

    offer_request = client.offer_requests.create(params: {
      slices:
        [
          {
            origin: trip.location,
            destination: trip.destination,
            departure_date: trip.start_date.strftime("%Y-%m-%d")
          },
          {
            origin: trip.destination,
            destination: trip.location,
            departure_date: trip.end_date.strftime("%Y-%m-%d")
          }
        ],
      passengers: Array.new(trip.adults, { "type": "adult" }),
      cabin_class: "economy",
      max_connections: 0
    })

    # puts "Created offer request: #{offer_request.id}"
    offers = client.offers.all(params: { offer_request_id: offer_request.id })

    # puts "Got #{offers.count} offers"

    selected_offers = offers.first(8)

    # puts "Selected offer #{selected_offer.id} to book"

    priced_offers = []

    selected_offers.each do |selected_offer|
      priced_offer = client.offers.get(selected_offer.id, params: { return_available_services: true })
      priced_offers << priced_offer
    end

    return priced_offers

    # puts "The final price for offer #{priced_offer.id} is #{priced_offer.total_amount} " \ "#{priced_offer.total_currency}"

  end
end
