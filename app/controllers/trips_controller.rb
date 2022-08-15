class TripsController < ApplicationController
  include Apitude

  def new
    @trip = Trip.new
  end

  def create
    @trip = Trip.new(trip_params)
    @trip.user = current_user
    if @trip.save
      @hotels = list_hotels(@trip.start_date.to_s,
                            @trip.end_date.to_s,
                            @trip.travellers,
                            @trip.budget * @trip.photel / 100)
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
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def index
  end

  def show
    @trip = Trip.find(params[:id])
  end

  def destroy
  end

  private

  def trip_params
    params.require(:trip).permit(:name, :location, :destination, :start_date, :end_date, :travellers, :budget)
  end
end
