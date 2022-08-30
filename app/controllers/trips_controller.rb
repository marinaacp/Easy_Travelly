class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy update]
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
        rate: hotel['reviews'][0]['rate'],
        reviewCount: hotel['reviews'][0]['reviewCount'],
        latitude: hotel['latitude'],
        longitude: hotel['longitude'],
        check_in: @trip.start_date,
        check_out: @trip.end_date
      )
    end
  end

  def create_flights
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
    if @trip.valid?
      @hotels = hotels(@trip)
      @flights = search_flights(@trip)
      if @hotels && @flights
        @trip.save
        create_hotels
        create_flights
        create_bookings
        @trip.update(
          budgetHotel: @trip.rooms * @trip.booking.hotel.price,
          budgetFlight: @trip.booking.flight.price
        )
        redirect_to @trip
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
  end

  def destroy
    @trip.destroy
    redirect_to trips_path
  end

  private

  def trip_params
    params.require(:trip).permit(
      :name, :location, :destination, :start_date, :end_date,
      :adults, :rooms, :budget, :budget
    )
  end

  def trip_update_params
    params.require(:trip).permit(:name)
  end

  def flight_params
    params.require(:trip).permit(
      :reservation_number, :departure_departure, :airport_departure_departure,
      :departure_arrival, :airport_departure_arrival, :departure_airline,
      :return_departure, :airport_return_departure, :return_arrival,
      :airport_return_arrival, :return_airline, :price, :budgetCurrency
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
