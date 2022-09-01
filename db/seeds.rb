# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Seeding countries and destinationsgst
require "uri"
require "json"
require "net/http"
require 'digest'

url = URI("https://api.test.hotelbeds.com/hotel-content-api/1.0/locations/countries?fields=description&language=ENG&from=1&to=300")

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Api-key"] = ENV['API_KEY']
string = ENV['API_KEY'] + ENV['API_SECRET'] + Time.now.to_i.to_s
hash = Digest::SHA256.hexdigest(string)
request["X-Signature"] = hash
request["Accept"] = "application/json"
response = https.request(request)
response = JSON.parse(response.read_body)

response['countries'].each do |country|
  puts "Creating destination #{country['description']['content']}"
  Country.create(
    code: country['code'],
    name: country['description']['content']
  )
end

# To fetch all destinations from the API 7 requests have to be made
# Fetching only the contries bellow:
countrycodes = ['ES', 'BR', 'FR', 'UK', 'PT', 'US', 'DK']

countrycodes.each do |code|
  url = URI("https://api.test.hotelbeds.com/hotel-content-api/1.0/locations/destinations?fields=countryCode, name&countryCodes=#{code}&language=ENG&from=1&to=1000&useSecondaryLanguage=false")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request["Api-key"] = ENV['API_KEY']
  string = ENV['API_KEY'] + ENV['API_SECRET'] + Time.now.to_i.to_s
  hash = Digest::SHA256.hexdigest(string)
  request["X-Signature"] = hash
  request["Accept"] = "application/json"
  response = https.request(request)
  response = JSON.parse(response.read_body)

  response['destinations'].each do |destination|
    puts "Creating destination #{destination['name']['content']}"
    Destination.create(
      code: destination['code'],
      name: destination['name']['content'],
      country: Country.find_by_code(destination['countryCode'])
    )
  end
end
