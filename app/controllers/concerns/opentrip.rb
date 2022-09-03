require "uri"
require "net/http"
require "json"

module Opentrip
  def search_activities(trip, city_name, country_code)
    # Get city lat long
    url = URI("https://api.opentripmap.com/0.1/en/places/geoname?name=#{city_name}&country=#{country_code}&apikey=#{ENV['OPENTRIP_KEY']}")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Accept"] = "application/json"
    response1 = https.request(request)
    response1 = JSON.parse(response1.read_body)

    url = URI("https://api.opentripmap.com/0.1/en/places/geoname?name=#{city_name}&apikey=#{ENV['OPENTRIP_KEY']}")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Accept"] = "application/json"
    response2 = https.request(request)
    response2 = JSON.parse(response2.read_body)

    if response1['error'] && response2['error']
      flash[:alert] = response['error']
      return nil
    else
      if response1['name']
        response = response1
      else
        response = response2
      end
      # Fetch Lat and Long from the location
      latitude = response['lat']
      longitude = response['lon']

      # Historic places
      url = URI("https://api.opentripmap.com/0.1/en/places/autosuggest?name=#{city_name}&radius=50000&lon=#{longitude}&lat=#{latitude}&src_geom=wikidata&src_attr=wikidata&kinds=historic&limit=20&apikey=#{ENV['OPENTRIP_KEY']}")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"

      response = https.request(request)
      response = JSON.parse(response.read_body)

      response['features'].each do |feature|
        xid = feature['properties']['xid']

        url = URI("https://api.opentripmap.com/0.1/en/places/xid/#{xid}?&apikey=#{ENV['OPENTRIP_KEY']}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request["Accept"] = "application/json"
        response = https.request(request)
        response = JSON.parse(response.read_body)
        if response['preview']
          Activity.create(
            kind: 'historic',
            name: response['name'],
            link: response['wikipedia'] || response['otm'],
            image: response['preview']['source'],
            trip: trip
          )
        end
      end
      # Cultural
      url = URI("https://api.opentripmap.com/0.1/en/places/autosuggest?name=#{city_name}&radius=50000&lon=#{longitude}&lat=#{latitude}&src_geom=wikidata&src_attr=wikidata&kinds=cultural&limit=20&apikey=#{ENV['OPENTRIP_KEY']}")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"

      response = https.request(request)
      response = JSON.parse(response.read_body)

      response['features'].each do |feature|
        xid = feature['properties']['xid']

        url = URI("https://api.opentripmap.com/0.1/en/places/xid/#{xid}?&apikey=#{ENV['OPENTRIP_KEY']}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request["Accept"] = "application/json"
        response = https.request(request)
        response = JSON.parse(response.read_body)
        if response['preview']
          Activity.create(
            kind: 'cultural',
            name: response['name'],
            link: response['wikipedia'] || response['otm'],
            image: response['preview']['source'],
            trip: trip
          )
        end
      end
      # Tourist facilities, foods
      url = URI("https://api.opentripmap.com/0.1/en/places/autosuggest?name=#{city_name}&radius=50000&lon=#{longitude}&lat=#{latitude}&kinds=foods&limit=30&apikey=#{ENV['OPENTRIP_KEY']}")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"

      response = https.request(request)
      response = JSON.parse(response.read_body)

      response['features'].each do |feature|
        xid = feature['properties']['xid']

        url = URI("https://api.opentripmap.com/0.1/en/places/xid/#{xid}?&apikey=#{ENV['OPENTRIP_KEY']}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request["Accept"] = "application/json"
        response = https.request(request)
        response = JSON.parse(response.read_body)
        if response['preview'].present? || response['url'].present?
          food = %w[restaurant food chef kitchen cafe pub bar restaurants eat juice drink]
          if response['preview'].present?
            image_url = response['preview']['source']
          else
            image_url = "https://source.unsplash.com/500x500/?#{food.sample}"
          end
          Activity.create(
            kind: 'foods',
            name: response['name'],
            link: response['wikipedia'] || response['url'] || response['otm'],
            image: image_url,
            trip: trip
          )

        end
      end
    end
  end
end
