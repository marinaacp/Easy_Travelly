class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy]
  include Apitude
  include Duffel

  def new
    @trip = Trip.new
    authorize @trip
  end

  def create
    @trip = Trip.new(trip_params)
    @trip.user = current_user
    if @trip.valid? && hotels(@trip) && search_flights(@trip)
      @trip.save
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

      @flights = flights(@trip)

      Flight.create(
        trip: @trip,
        reservation_number: "123456",
        # ida
        departure_departure: @trip.start_date,
        airport_departure_departure: "nosso",
        departure_arrivel: @trip.end_date,
        airport_departure_arrival: "nosso 2",
        # volta
        return_departure: @trip.start_date,
        airport_return_departure: "nosso 3",
        return_arrivel: @trip.end_date,
        airport_return_arrival: "nosso 4"
      )


      @booking = Booking.create(
        trip: @trip,
        hotel: @trip.hotels[0],
        flight: Flight.last
      )
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
    params.require(:trip).permit(:name, :location, :destination, :start_date, :end_date, :adults, :rooms, :children, :budget)
  end

  def flight_params
    params.require(:trip).permit(:reservation_number, :departure_departure, :airport_departure_departure, :departure_arrivel, :airport_departure_arrival, :return_departure, :airport_return_departure, :return_arrivel, :airport_return_arrival, :price, :currency)
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
