class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy]
  include Apitude
  include Duffel

  def new
    @trip = Trip.new
    authorize @trip
  end

  def create_hotels
    @hotels = hotels(@trip)
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
    @flights = flights(@trip)
    @flights.each do |flight|
      Flight.create(
        trip: @trip,
        reservation_number: flight.id,
        price: flight.total_amount,
        currency: flight.tax_currency,
        # ida
        departure_airline: flight.slices[0]["segments"][0]["operating_carrier"]["name"],
        departure_departure: flight.slices[0]["origin"]["name"],
        airport_departure_departure: flight.slices[0]['segments'][0]['origin']['name'],
        departure_arrival: flight.slices[0]["destination"]["name"],
        airport_departure_arrival: flight.slices[0]['segments'][0]["destination"]["name"],
        # volta
        return_airline: flight.slices[1]["segments"][0]["operating_carrier"]["name"],
        return_departure: flight.slices[1]["origin"]["name"],
        airport_return_departure: flight.slices[1]['segments'][0]["origin"]["name"],
        return_arrival: flight.slices[1]["destination"]["name"],
        airport_return_arrival: flight.slices[1]['segments'][0]["destination"]["name"]
      )
    end
  end

  def create_bookings
    @booking = Booking.create(
      trip: @trip,
      hotel: @trip.hotels[0],
      flight: Flight.last
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
    if @trip.valid? && search_flights(@trip) && hotels(@trip)
      @trip.save
      create_hotels
      create_flights
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
