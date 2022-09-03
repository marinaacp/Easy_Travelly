class FlightsController < ApplicationController
  def new
    @flight = Flight.new
    @trip = Trip.find(params[:trip_id])
    @flight.trip = @trip
    authorize @flight
  end

  def create
    @trip = Trip.find(params[:trip_id])
    @flight = Flight.create(flight_params)
    if @flight.valid?
      authorize @flight
      @flight.save
      redirect_to edit_booking_path(@trip.booking)
    else
      render :new
    end
  end

  private

  def flight_params
    params.permit(
      :reservation_number, :price, :currency, :emissions, :departure_start_time, :departure_end_time, :departure_class,
      :departure_baggage, :departure_airline, :logo_departure_airline, :aircraft_departure_airline,
      :departure_departure, :airport_departure_departure, :terminal_departure_departure, :departure_arrival,
      :airport_departure_arrival, :terminal_departure_arrival, :return_start_time, :return_end_time, :return_class,
      :return_baggage, :return_airline, :logo_return_airline, :aircraft_return_airline, :return_departure,
      :airport_return_departure, :terminal_return_departure, :return_arrival, :airport_return_arrival,
      :terminal_return_arrival
    )
  end
end
