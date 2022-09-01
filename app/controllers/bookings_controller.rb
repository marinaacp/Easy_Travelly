class BookingsController < ApplicationController
  before_action :set_booking, only: %i[edit update]

  def edit
    authorize @booking
  end

  def update
    hotel = Hotel.find(booking_params[:hotels])
    flight = Flight.find(booking_params[:flights])
    if @booking.update(hotel: hotel, flight: flight)
      @booking.trip.update(
        budgetHotel: hotel.price * @booking.trip.rooms,
        budgetFlight: flight.price
      )
      redirect_to trip_path(@booking.trip)
    else
      render :edit
    end
    authorize @booking
  end

  private

  def booking_params
    params.permit(:hotels, :flights)
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
