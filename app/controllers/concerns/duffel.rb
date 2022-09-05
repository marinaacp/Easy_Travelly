require "duffel_api"
require "bigdecimal"
require "json"
require "uri"
require "net/http"
require "digest"

module Duffel
  def search_flights(trip, destination_city, departure_city)
    client = DuffelAPI::Client.new(
      access_token: ENV.fetch("DUFFEL_ACCESS_TOKEN")
    )

    # Getting IATA CODE for Destination city
    url = URI("https://api.duffel.com/places/suggestions?query=#{destination_city.split('-')[0]}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    # request["Accept-Encoding"] = "gzip"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{ENV['DUFFEL_ACCESS_TOKEN']}"
    request["Duffel-Version"] = "beta"

    response = https.request(request)
    response = JSON.parse(response.read_body)
    if response['data'].empty?
      destination_iata_code = trip.destination
    else
      destination_iata_code = response['data'][0]['iata_code']
    end
    ############################################################################

    # Getting IATA CODE for Departure city
    url = URI("https://api.duffel.com/places/suggestions?query=#{departure_city.split('-')[0]}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    # request["Accept-Encoding"] = "gzip"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{ENV['DUFFEL_ACCESS_TOKEN']}"
    request["Duffel-Version"] = "beta"

    response = https.request(request)
    response = JSON.parse(response.read_body)
    if response['data'].empty?
      departure_iata_code = trip.location
    else
      departure_iata_code = response['data'][0]['iata_code']
    end
    ############################################################################

    offer_request = client.offer_requests.create(params: {
      slices:
        [
          {
            origin: departure_iata_code,
            destination: destination_iata_code,
            departure_date: trip.start_date.strftime("%Y-%m-%d")
          },
          {
            origin: destination_iata_code,
            destination: departure_iata_code,
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
      priced_offer = client.offers.get(selected_offer.id)
      priced_offers << priced_offer
    end

    return priced_offers

    # puts "The final price for offer #{priced_offer.id} is #{priced_offer.total_amount} " \ "#{priced_offer.total_currency}"
  end
end
