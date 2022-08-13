require "uri"
require "json"
require "net/http"
require 'digest'

module Apitude
  def list_hotels(check_in, check_out)
    url = URI("https://api.test.hotelbeds.com/hotel-api/1.0/hotels")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Api-key"] = ENV['API_KEY']
    string = ENV['API_KEY'] + ENV['API_SECRET'] + Time.now.to_i.to_s
    hash = Digest::SHA256.hexdigest(string)
    request["X-Signature"] = hash
    request["Accept"] = "application/json"
    # request["Accept-Encoding"] = "gzip"
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({
      'stay': {
        'checkIn': check_in,
        'checkOut': check_out
      },
      'occupancies': [
        {
          "rooms": 1,
          "adults": 2,
          "children": 0
        }
      ],
      "destination": {
        "code": "LON"
      }
    })

    response = https.request(request)
    response = JSON.parse(response.read_body)
    puts '-------------------'
    puts response['hotels']['hotels'].count
    response['hotels']['hotels'].each do |hotel|
      puts hotel['name']
    end
    puts '-------------------'
  end
end
