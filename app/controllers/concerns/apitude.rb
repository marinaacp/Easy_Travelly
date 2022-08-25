require "uri"
require "json"
require "net/http"
require 'digest'

module Apitude
  def list_hotels(trip)
    url = URI("https://api.test.hotelbeds.com/hotel-api/1.0/hotels")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Api-key"] = ENV['API_KEY']
    string = ENV['API_KEY'] + ENV['API_SECRET'] + Time.now.to_i.to_s
    hash = Digest::SHA256.hexdigest(string)
    request["X-Signature"] = hash
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({
      'stay': {
        'checkIn': trip.start_date,
        'checkOut': trip.end_date
      },
      'occupancies': [
        {
          "rooms": trip.rooms,
          "adults": trip.adults,
          "children": trip.children
        }
      ],
      "destination": {
        "code": trip.destination
      },
      "filter": {
        "maxRate": trip.budget * trip.photel / 100
      }
    })

    response = https.request(request)

    response = JSON.parse(response.read_body)
    raise

    if response['error']
      flash[:alert] = response['error']['message']
      return nil
    end

    response = response['hotels']['hotels']
    return response[0..10] if response.count >= 10

    return response
  end

  def countries_and_destinations
    url = URI("https://api.test.hotelbeds.com/hotel-content-api/1.0/locations/countries?fields=all&language=ENG&from=1&to=203")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Api-key"] = ENV['API_KEY']
    string = ENV['API_KEY'] + ENV['API_SECRET'] + Time.now.to_i.to_s
    hash = Digest::SHA256.hexdigest(string)
    request["X-Signature"] = hash
    request["Accept"] = "application/json"

    # Countries
    response_countries = https.request(request)
    country_list = []
    response_countries["countries"].each do |country|
      h = {
        code: country['code'],
        name: country['description']['content']
      }
      country_list << h
    end

    url = URI("https://api.test.hotelbeds.com/hotel-content-api/1.0/locations/destinations?fields=all&language=ENG&from=1&to=100&useSecondaryLanguage=false")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Api-key"] = ENV['API_KEY']
    string = ENV['API_KEY'] + ENV['API_SECRET'] + Time.now.to_i.to_s
    hash = Digest::SHA256.hexdigest(string)
    request["X-Signature"] = hash
    request["Accept"] = "application/json"

    response = https.request(request)
    return JSON.parse(response.read_body)
  end
end
