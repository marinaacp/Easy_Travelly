class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy]
  include Apitude

  def new
    @trip = Trip.new
    authorize @trip
  end

  def create
    @trip = Trip.new(trip_params)
    @trip.user = current_user
    if @trip.valid? && hotels(@trip)
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

      3.times do
        Flight.create(
          departure: @trip.location,
          price: @trip.budget * @trip.pflight / 100 * [0.8, 0.7, 0.5].sample,
          trip: @trip
        )
      end

      @booking = Booking.create(
        trip: @trip,
        hotel: @trip.hotels[0],
        flight: Flight.create(
          departure: @trip.location,
          price: @trip.budget * @trip.pflight / 100,
          trip: @trip
        )
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
    #@trips = Trip.where(user: current_user)
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

  def hotels(trip)
    list_hotels(trip)
  end

  def set_trip
    @trip = Trip.find(params[:id])
    authorize @trip
  end
end
