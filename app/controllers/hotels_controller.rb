class HotelsController < ApplicationController
  before_action :set_hotel, only: %i[edit update]

  def edit
  end

  def update
    if @hotel.update(hotel_params)
      redirect_to trip_path(@hotel.trip)
    else
      render :edit
    end
  end

  private

  def hotel_params
    params.permit(:name, :check_in, :check_out, :price, :currency, :category, :zone_name )
  end

  def set_hotel
    @hotel = Hotel.find(params[:id])
    authorize @hotel
  end
end
