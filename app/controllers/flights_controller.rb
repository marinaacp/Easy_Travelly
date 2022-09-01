class FlightsController < ApplicationController
  before_action :set_flight, only: %i[edit update]

  def edit
  end

  def update
    if @flight.update(flight_params)
      redirect_to trip_path
    else
      render :edit
    end
  end

  private

  def flight_params
    params.permit(:reservation_number, :departure_departure, :airport_departure_departure,
                  :departure_arrival, :airport_departure_arrival, :departure_airline,
                  :return_departure, :airport_return_departure, :return_arrival,
                  :airport_return_arrival, :return_airline, :price, :currency)
  end

  def set_flight
    @flight = Flight.find(params[:id])
    authorize @flight
  end
end
