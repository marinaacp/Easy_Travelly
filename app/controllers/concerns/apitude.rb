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

    if response['error']
      flash[:alert] = response['error']['message']
      return nil
    end

    response = response['hotels']['hotels']
    return response[0..10] if response.count >= 10

    return response
  end
end
