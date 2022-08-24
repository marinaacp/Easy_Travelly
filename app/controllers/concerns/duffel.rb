require "duffel_api"
require "bigdecimal"

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
      passengers: [{
                    age: 28,
                  }],
      cabin_class: "business",
      max_connections: 0,
    })
    # puts "Created offer request: #{offer_request.id}"
    offers = client.offers.all(params: { offer_request_id: offer_request.id })

    puts "Got #{offers.count} offers"

    selected_offer = offers.first

    puts "Selected offer #{selected_offer.id} to book"

    priced_offer = client.offers.get(selected_offer.id,
                                    params: { return_available_services: true })

    puts "The final price for offer #{priced_offer.id} is #{priced_offer.total_amount} " \
        "#{priced_offer.total_currency}"

    raise

    return_offer = {
      # ida
      reservation_number: offer_request.id,
      departure_departure: offer_request.slices[0]["origin"]["name"],
      airport_departure_departure: offer_request.slices[0]["origin"]["airports"][0]["name"],
      departure_arrivel: offer_request.slices[0]["destination"]["name"],
      airport_departure_arrival: offer_request.slices[0]["destination"]["airports"][0]["name"],
      # volta
      return_departure: offer_request.slices[1]["origin"]["name"],
      airport_return_departure: offer_request.slices[1]["origin"]["airports"][0]["name"],
      return_arrivel: offer_request.slices[1]["destination"]["name"],
      airport_return_arrival: offer_request.slices[1]["destination"]["airports"][0]["name"]
    }
    return return_offer
  end
end
