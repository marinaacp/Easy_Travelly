class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy]
  include Apitude
  include Duffel

  def new
    @trip = Trip.new
    authorize @trip
  end

  def create_hotels
    @hotels.each do |hotel|
      Hotel.create(
        trip: @trip,
        name: hotel['name'],
        category: hotel['categoryName'],
        zone_name: hotel['zoneName'],
        price: hotel['minRate'],
        currency: hotel['currency'],
        check_in: @trip.start_date,
        check_out: @trip.end_date
      )
    end
  end

  def create_flights
    @flights.each do |flight|
      Flight.create(
        trip: @trip,
        reservation_number: flight.id, # numero da reserva
        price: flight.total_amount, # valor total com .tax_amount
        currency: flight.total_currency, # moeda do valor total (tax_amount tem sua própria currency. Em geral é a mesma)
        emissions: flight.total_emissions_kg, # total emissão ida e volta
        # ida
        departure_start_time: flight.slices[0]["segments"][0]['departing_at'], # hora inicio da viagem
        departure_end_time: flight.slices[0]["segments"][0]['arriving_at'], # hora fim da viagem
        departure_class: flight.slices[0]["segments"][0]['passengers'][0]['cabin_class'], # classe da viagem ("first", "business", "premium_economy", or "economy")
        # em tese cabin_class tem uma p/ cada passageiro. aqui estou pegando só uma p todos eles. Mesma logica para baggage
        departure_baggage: flight.slices[0]["segments"][0]['passengers'][0]['baggages'][0]['quantity'], #numero de bagagens. Como a class era p ter uma p/ cada
        departure_airline: flight.slices[0]["segments"][0]["operating_carrier"]["name"], # companhia aérea
        logo_departure_airline: flight.slices[0]["segments"][0]["operating_carrier"]["logo_symbol_url"], # logo companhia aérea
        aircraft_departure_airline: flight.slices[0]["segments"][0]['aircraft']['name'], # avião da ida
        departure_departure: flight.slices[0]["segments"][0]["origin"]['city_name'], # cidade de saída
        airport_departure_departure: flight.slices[0]['segments'][0]['origin']['name'], # aeroporto da cidade de saída
        terminal_departure_departure: flight.slices[0]["segments"][0]["origin_terminal"], # terminal do aeroportode saída
        departure_arrival: flight.slices[0]["segments"][0]["destination"]['city_name'], # cidade de chegada
        airport_departure_arrival: flight.slices[0]['segments'][0]['destination']['name'], # aeroporto da cidade de chegada
        terminal_departure_arrival: flight.slices[0]["segments"][0]["destination_terminal"], # terminal do aeroporto de chegada
        # volta
        return_start_time: flight.slices[1]["segments"][0]['departing_at'], # hora inicio da viagem
        return_end_time: flight.slices[1]["segments"][0]['arriving_at'], # hora fim da viagem
        return_class: flight.slices[1]["segments"][0]['passengers'][0]['cabin_class'], # classe da viagem ("first", "business", "premium_economy", or "economy")
        # em tese cabin_class tem uma p/ cada passageiro. aqui estou pegando só uma p todos eles. Mesma logica para baggage
        return_baggage: flight.slices[1]["segments"][0]['passengers'][0]['baggages'][0]['quantity'], # numero de bagagens. Como a class era p ter uma p/ cada
        return_airline: flight.slices[1]["segments"][0]["operating_carrier"]["name"], # companhia aérea
        logo_return_airline: flight.slices[1]["segments"][0]["operating_carrier"]["logo_symbol_url"], # logo companhia aérea
        aircraft_return_airline: flight.slices[1]["segments"][0]['aircraft']['name'], # avião da volta
        return_departure: flight.slices[1]["segments"][0]["origin"]['city_name'], # cidade de saída
        airport_return_departure: flight.slices[1]['segments'][0]['origin']['name'], # aeroporto da cidade de saída
        terminal_return_departure: flight.slices[1]["segments"][0]["origin_terminal"], # terminal do aeroportode saída
        return_arrival: flight.slices[1]["segments"][0]["destination"]['city_name'], # cidade de chegada
        airport_return_arrival: flight.slices[1]['segments'][0]['destination']['name'], # aeroporto da cidade de chegada
        terminal_return_arrival: flight.slices[1]["segments"][0]["destination_terminal"] # terminal do aeroporto de chegada
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

  # def currency_usd
  #   # Money.ca_dollar(100).exchange_to("USD")  # => Money.from_cents(80, "USD")
  #   if Booking.hotel[:currency] == 'EUR'
  #     Money.euro(Booking.hotel[:price]).exchange_to("USD")
  #     Booking.hotel[:currency] = "USD"
  #   end
  # end

  def create
    @trip = Trip.new(trip_params)
    @trip.user = current_user
    @hotels = hotels(@trip)
    @flights = search_flights(@trip)
    # raise
    if @trip.valid? && @hotels && @flights
      @trip.save
      create_hotels
      create_flights
      raise
      create_bookings
      redirect_to @trip
    elsif @trip.valid?
      # flash[:alert] = 'No result found'
      @trip.budget_error
      render :new
    else
      render :new
    end
    authorize @trip
  end

  def edit
  end

  def update
  end

  def index
    # @trips = Trip.where(user: current_user)
    @trips = policy_scope(Trip)
  end

  def show
  end

  def destroy
    @trip.destroy
    redirect_to trips_path
  end

  private

  def trip_params
    params.require(:trip).permit(
      :name, :location, :destination, :start_date, :end_date,
      :adults, :rooms, :children, :budget
    )
  end

  def flight_params
    params.require(:trip).permit(
      :reservation_number, :departure_departure, :airport_departure_departure,
      :departure_arrival, :airport_departure_arrival, :departure_airline,
      :return_departure, :airport_return_departure, :return_arrival,
      :airport_return_arrival, :return_airline, :price, :currency
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
