require "open-uri"
require "nokogiri"

class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy update]
  include Apitude
  include Duffel
  include Opentrip

  def new
    @trip = Trip.new
    authorize @trip
  end

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

  def create
    @trip = Trip.new(trip_params)
    # Adjustes the budget to euro
    @trip.budget = @trip.budget / 5.22 if @trip.budgetCurrency == 'brazilian-real'
    @trip.user = current_user
    if @trip.valid?
      @hotels = hotels(@trip)
      @destination_city = DestinationAttr.find_by_city_code(@trip.destination).city_name
      @departure_city = DestinationAttr.find_by_city_code(@trip.location).city_name
      @flights = search_flights(@trip, @destination_city, @departure_city)
      if @hotels && @flights
        @trip.save
        if create_hotels && create_flights && create_bookings && create_activities

          url = "https://source.unsplash.com/200x200/?#{@destination_city}"
          img_url = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(url))).children.children.children[1].attributes['href'].value

          @trip.update(
            budgetHotel: @trip.rooms * @trip.booking.hotel.price,
            budgetFlight: @trip.booking.flight.price,
            image_url: img_url || url
          )

          redirect_to @trip
        else
          @trip.destroy
          @trip = Trip.new
          @trip.generic_error
          render :new
        end
      else
        @trip.budget_error
        render :new
      end
    else
      render :new
    end
    authorize @trip
  end

  def edit; end

  def update
    respond_to do |format|
      if @trip.update(trip_update_params)
        format.html { redirect_to @trip }
        format.json # Follow the classic Rails flow and look for a update.json view
      else
        format.html { render "trips/show" }
        format.json # Follow the classic Rails flow and look for a update.json view
      end
    end
  end

  def index
    # @trips = Trip.where(user: current_user)
    @trips = policy_scope(Trip)
  end

  def show
    @city = DestinationAttr.find_by_city_code(@trip.destination).city_name
  end

  def destroy
    @trip.destroy
    redirect_to trips_path
  end

  private

  def trip_params
    params.require(:trip).permit(
      :name, :location, :destination, :start_date, :end_date,
      :adults, :rooms, :budget, :budgetCurrency
    )
  end

  def trip_update_params
    params.require(:trip).permit(:name)
  end

  def flight_params
    params.require(:trip).permit(
      :reservation_number, :price, :currency, :emissions, :departure_start_time, :departure_end_time, :departure_class,
      :departure_baggage, :departure_airline, :logo_departure_airline, :departure_departure,
      :airport_departure_departure, :departure_arrival, :airport_departure_arrival, :return_start_time,
      :return_end_time, :return_class, :return_baggage, :return_airline, :logo_return_airline, :return_departure,
      :airport_return_departure, :return_arrival, :airport_return_arrival
    )
  end

  def hotels(trip)
    list_hotels(trip)
  end

  def flights(trip)
    search_flights(trip)
  end

  def set_trip
    @trip = Trip.find(params[:id])
    authorize @trip
  end
end
