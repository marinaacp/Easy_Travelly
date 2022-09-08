# Seeding countries and destinations
require "uri"
require "json"
require "net/http"
require 'digest'

# If there is no country seeded, seed from APItude
if Country.count.zero?
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
  sleep(30)
end

# To fetch all destinations from the API 7 requests have to be made
# Fetching only the contries bellow:

# countrycodes = ['US', 'ES', 'BR', 'FR', 'UK', 'PT', 'AR', 'IT', 'DE']

# countrycodes.each do |code|
#   url = URI("https://api.test.hotelbeds.com/hotel-content-api/1.0/locations/destinations?fields=countryCode, name&countryCodes=#{code}&language=ENG&from=1001&to=1797&useSecondaryLanguage=false")

#   https = Net::HTTP.new(url.host, url.port)
#   https.use_ssl = true
#   request = Net::HTTP::Get.new(url)
#   request["Api-key"] = ENV['API_KEY']
#   string = ENV['API_KEY'] + ENV['API_SECRET'] + Time.now.to_i.to_s
#   hash = Digest::SHA256.hexdigest(string)
#   request["X-Signature"] = hash
#   request["Accept"] = "application/json"
#   response = https.request(request)
#   response = JSON.parse(response.read_body)

#   response['destinations'].each do |destination|
#     puts "Creating destination #{destination['name']['content']}"
#     new_destination = Destination.create(
#       code: destination['code'],
#       name: destination['name']['content'],
#       country: Country.find_by_code(destination['countryCode'])
#     )
#     DestinationAttr.create(
#       city_name: new_destination.name,
#       country_name: new_destination.country.name,
#       city_code: new_destination.code,
#       country_code: new_destination.country.code
#     )
#   end
# end
###############################################################################

# Populating some Destinations
cities = ['New York City - NYC', 'Los Angeles', 'Boston', 'Rio de Janeiro', 'Belo Horizonte', 'Sao Paulo', 'Curitiba', 'Brasilia', 'Porto Alegre', 'Fortaleza' , 'Manaus', 'Paris', 'Barcelona', 'Madrid', 'London']
cities_codes = %w[NYC LAX BOS RIO BHZ SAO CUR BSB POO FTZ MNA PAR BCN MAD LON]
countries = ["United States", "United States", "United States", "Brazil", "Brazil", "Brazil", "Brazil", "Brazil", "Brazil", "Brazil", "Brazil", "France", "Spain", "Spain", "United Kingdom"]
countries_codes = %w[US US US BR BR BR BR BR BR BR BR FR ES ES UK]

cities.each_with_index do |city, index|
  DestinationAttr.create(
          city_name: city,
          country_name: countries[index],
          city_code: cities_codes[index],
          country_code: countries_codes[index]
        )
end
