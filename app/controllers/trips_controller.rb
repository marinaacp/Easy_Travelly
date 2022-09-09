require "open-uri"
require "nokogiri"

class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy update]
  include Apitude
  include Duffel
  include Opentrip

  def new
    @trip = Trip.new
    authorize @trip
  end

  def create
    @trip = Trip.new(trip_params)
    # Adjustes the budget to euro
    @trip.budget = @trip.budget / 5.22 if @trip.budgetCurrency == 'brazilian-real'
    @trip.user = current_user
    if @trip.valid?
      @trip.save
      ApisJob.perform_later(@trip.id)
      flash[:notice] = "Creating your trip"
      redirect_to trips_path
    else
      @trip.budget_error
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
    @city = DestinationAttr.find_by_city_code(@trip.destination).city_name
  end

  def destroy
    @trip.destroy
    redirect_to trips_path
  end

  private

  def trip_params
    params.require(:trip).permit(
      :name, :location, :destination, :start_date, :end_date,
      :adults, :rooms, :budget, :budgetCurrency
    )
  end

  def trip_update_params
    params.require(:trip).permit(:name)
  end

  def flight_params
    params.require(:trip).permit(
      :reservation_number, :price, :currency, :emissions, :departure_start_time, :departure_end_time, :departure_class,
      :departure_baggage, :departure_airline, :logo_departure_airline, :departure_departure,
      :airport_departure_departure, :departure_arrival, :airport_departure_arrival, :return_start_time,
      :return_end_time, :return_class, :return_baggage, :return_airline, :logo_return_airline, :return_departure,
      :airport_return_departure, :return_arrival, :airport_return_arrival
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
