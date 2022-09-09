require "open-uri"
require "nokogiri"

class ApisJob < ApplicationJob
  queue_as :default
  include Apitude
  include Duffel
  include Opentrip

  def create_hotels
    @hotels.each_with_index do |hotel, index|
      hotel_sample = %w[hotel bed hotels hostel room building pillow cozy]
      url = "https://source.unsplash.com/200x200/?#{hotel_sample[index]}"
      img_url = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(url))).children.children.children[1].attributes['href'].value

      Hotel.create(
        trip: @trip,
        name: hotel['name'],
        category: hotel['categoryName'],
        zone_name: hotel['zoneName'],
        price: hotel['minRate'],
        currency: hotel['currency'],
        rate: hotel['reviews'][0]['rate'],
        reviewCount: hotel['reviews'][0]['reviewCount'],
        latitude: hotel['latitude'],
        longitude: hotel['longitude'],
        check_in: @trip.start_date,
        check_out: @trip.end_date,
        image_url: img_url
      )
    end
  end

  def create_flights
    @flights.each do |flight|
      # Checa se existe bagagem
      # Numero de bagagens. Como a class era p ter uma p/ cada
      if flight.slices[0]["segments"][0]['passengers'][0]['baggages'].empty?
        departure_baggage = 0
      else
        departure_baggage = flight.slices[0]["segments"][0]['passengers'][0]['baggages'][0]['quantity']
      end

      if flight.slices[1]["segments"][0]['passengers'][0]['baggages'].empty?
        return_baggage = 0
      else
        return_baggage = flight.slices[1]["segments"][0]['passengers'][0]['baggages'][0]['quantity']
      end

      Flight.create(
        trip: @trip,
        reservation_number: flight.id, # Numero da reserva
        price: flight.total_amount, # Valor total com .tax_amount
        currency: flight.total_currency, # moeda do valor total (tax_amount tem sua própria currency. Em geral é a mesma)
        emissions: flight.total_emissions_kg, # total emissão ida e volta
        # ida
        departure_start_time: flight.slices[0]["segments"][0]['departing_at'], # hora inicio da viagem
        departure_end_time: flight.slices[0]["segments"][0]['arriving_at'], # hora fim da viagem
        # classe da viagem ("first", "business", "premium_economy", or "economy")
        departure_class: flight.slices[0]["segments"][0]['passengers'][0]['cabin_class'],
        # Em tese cabin_class tem uma p/ cada passageiro. aqui estou pegando só uma p todos eles.
        # Mesma logica para baggage
        departure_baggage: departure_baggage,

        departure_airline: flight.slices[0]["segments"][0]["operating_carrier"]["name"], # companhia aérea
        logo_departure_airline: flight.slices[0]["segments"][0]["operating_carrier"]["logo_symbol_url"], # logo companhia aérea
        # aircraft_departure_airline: flight.slices[0]["segments"][0]['aircraft']['name'], # avião da ida
        departure_departure: flight.slices[0]["segments"][0]["origin"]['city_name'], # cidade de saída
        airport_departure_departure: flight.slices[0]['segments'][0]['origin']['name'], # aeroporto da cidade de saída
        # terminal_departure_departure: flight.slices[0]["segments"][0]["origin_terminal"], # terminal do aeroportode saída
        departure_arrival: flight.slices[0]["segments"][0]["destination"]['city_name'], # cidade de chegada
        airport_departure_arrival: flight.slices[0]['segments'][0]['destination']['name'], # aeroporto da cidade de chegada
        # terminal_departure_arrival: flight.slices[0]["segments"][0]["destination_terminal"], # terminal do aeroporto de chegada
        # volta. Basta mudar de slice
        return_start_time: flight.slices[1]["segments"][0]['departing_at'], # hora inicio da viagem
        return_end_time: flight.slices[1]["segments"][0]['arriving_at'], # hora fim da viagem
        return_class: flight.slices[1]["segments"][0]['passengers'][0]['cabin_class'], # classe da viagem ("first", "business", "premium_economy", or "economy")
        # em tese cabin_class tem uma p/ cada passageiro. aqui estou pegando só uma p todos eles. Mesma logica para baggage
        return_baggage: return_baggage, # numero de bagagens. Como a class era p ter uma p/ cada
        return_airline: flight.slices[1]["segments"][0]["operating_carrier"]["name"], # companhia aérea
        logo_return_airline: flight.slices[1]["segments"][0]["operating_carrier"]["logo_symbol_url"], # logo companhia aérea
        # aircraft_return_airline: flight.slices[1]["segments"][0]['aircraft']['name'], # avião da volta
        return_departure: flight.slices[1]["segments"][0]["origin"]['city_name'], # cidade de saída
        airport_return_departure: flight.slices[1]['segments'][0]['origin']['name'], # aeroporto da cidade de saída
        # terminal_return_departure: flight.slices[1]["segments"][0]["origin_terminal"], # terminal do aeroportode saída
        return_arrival: flight.slices[1]["segments"][0]["destination"]['city_name'], # cidade de chegada
        airport_return_arrival: flight.slices[1]['segments'][0]['destination']['name'] # aeroporto da cidade de chegada
        # terminal_return_arrival: flight.slices[1]["segments"][0]["destination_terminal"] # terminal do aeroporto de chegada
      )
    end
  end

  def create_bookings
    @booking = Booking.create(
      trip: @trip,
      hotel: @trip.hotels[0],
      flight: @trip.flights[0]
    )
  end

  def create_activities
    # @city_name = DestinationAttr.find_by_city_code(@trip.destination).city_name
    @destination_country_code = DestinationAttr.find_by_city_code(@trip.destination).country_code
    @activities = search_activities(@trip, @destination_city, @destination_country_code)
  end

  def perform(trip_id)
    @trip = Trip.find(trip_id)
    puts "Trip to #{@trip.destination}"
    @hotels = hotels(@trip)
    @destination_city = DestinationAttr.find_by_city_code(@trip.destination).city_name
    @departure_city = DestinationAttr.find_by_city_code(@trip.location).city_name
    @flights = search_flights(@trip, @destination_city, @departure_city)
    if @hotels && @flights
      if create_hotels && create_flights && create_bookings && create_activities
        url = "https://source.unsplash.com/200x200/?#{@destination_city}"
        img_url = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(url))).children.children.children[1].attributes['href'].value

        @trip.update(
          budgetHotel: @trip.rooms * @trip.booking.hotel.price,
          budgetFlight: @trip.booking.flight.price,
          image_url: img_url || url
        )

        flash[:notice] = "Trip to #{destination_city} created!"
      else
        flash[:notice] = "Could not create trip to #{destination_city}"
        @trip.destroy
      end

    end
  end
end
