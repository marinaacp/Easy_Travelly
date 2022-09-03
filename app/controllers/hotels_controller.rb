class HotelsController < ApplicationController
  def new
    @hotel = Hotel.new
    @trip = Trip.find(params[:trip_id])
    @hotel.trip = @trip
    authorize @hotel
  end

  def create
    @trip = Trip.find(params[:trip_id])
    @hotel = Hotel.create(hotel_params)
    @hotel.update(
      trip: @trip,
      check_in: @trip.start_date,
      check_out: @trip.end_date
    )
    if @hotel.valid?
      authorize @hotel
      @hotel.save
      redirect_to edit_booking_path(@trip.booking)
    else
      render :new
    end
  end

  private

  def hotel_params
    params.require(:hotel).permit(:name, :price)
  end
end
