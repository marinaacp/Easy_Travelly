class HotelsController < ApplicationController
  before_action :set_hotel, only: %i[new create]

  def new
    @hotel = Hotel.new
    authorize @hotel
  end

  def create
    @hotel = Hotel.create(hotel_params)
    @hotel.user = current_user
    if @hotel.valid?
      authorize @hotel
      @hotel.save
      redirect_to trip_path
    else
      render :new
    end
  end

  private

  def hotel_params
    params.permit(:name, :check_in, :check_out, :price, :currency, :category, :zone_name)
  end
end
