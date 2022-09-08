require "uri"
require "net/http"
require "json"
require "open-uri"
require "nokogiri"

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

      # Get 30 activities (Historic | Cultural); Only rates above 2 (scale 1 to 3)
      url = URI("https://api.opentripmap.com/0.1/en/places/radius?lon=#{longitude}&lat=#{latitude}&radius=10000&kinds=cultural%2Chistoric&rate=2&limit=30&apikey=#{ENV['OPENTRIP_KEY']}")

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
          food = %w[restaurant food chef kitchen cafe pub bar restaurants eat drink]
          if response['preview'].present?
            image_url = response['preview']['source']
          else
            url = "https://source.unsplash.com/500x500/?#{food.sample}"
            image_url = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(url))).children.children.children[1].attributes['href'].value
          end
          Activity.create(
            kinds: response['kinds'].split(','),
            name: response['name'],
            link: response['wikipedia'] || response['otm'],
            image: image_url,
            rating: response['rate'],
            trip: trip
          )
        end
      end

      # Get 8 places for FOODS
      rate = 3
      n_foods_activities = Activity.where(trip: trip).where("kinds @> ?", '{foods}').count

      while n_foods_activities < 8 && rate.positive?
        url = URI("https://api.opentripmap.com/0.1/en/places/radius?lon=#{longitude}&lat=#{latitude}&radius=20000&rate=#{rate}&kinds=foods&limit=8&apikey=#{ENV['OPENTRIP_KEY']}")

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["Accept"] = "application/json"

        response = https.request(request)
        response = JSON.parse(response.read_body)
        unless response['features'].nil?
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
              food = %w[restaurant food chef kitchen cafe pub bar restaurants eat drink]
              if response['preview'].present?
                image_url = response['preview']['source']
              else
                url = "https://source.unsplash.com/500x500/?#{food.sample}"
                image_url = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(url))).children.children.children[1].attributes['href'].value
              end
              Activity.create(
                kinds: response['kinds'].split(','),
                name: response['name'],
                link: response['wikipedia'] || response['otm'],
                image: image_url,
                rating: response['rate'][0],
                trip: trip
              )
            end
          end
        end
        n_foods_activities = Activity.where(trip: trip).where("kinds @> ?", '{foods}').count
        rate -= 1
      end
    end
    return Activity.where(trip: trip).count
  end
end
