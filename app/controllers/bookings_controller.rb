class BookingsController < ApplicationController
  def edit
    @booking = Booking.find(params[:id])
  end

  def update
    @booking = Booking.find(params[:id])
    hotel = Hotel.find(booking_params[:hotels])
    flight = Flight.find(booking_params[:flights])
    if @booking.update(hotel: hotel, flight: flight)
      redirect_to trip_path(@booking.trip)
    else
      render :edit
    end
  end

  private

  def booking_params
    params.permit(:hotels, :flights)
  end
end
