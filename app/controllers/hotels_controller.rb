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
    @destination_city = DestinationAttr.find_by_city_code(@trip.destination).city_name
    url_trip = "https://source.unsplash.com/200x200/?#{@destination_city}"
    img_url_trip = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(url_trip))).children.children.children[1].attributes['href'].value
    hotel_sample = %w[hotel hotels bed beds hostel room building]
    url_hotel = "https://source.unsplash.com/200x200/?#{hotel_sample.sample}"
    img_url_hotel = Nokogiri::HTML.parse(Net::HTTP.get(URI.parse(url_hotel))).children.children.children[1].attributes['href'].value

    @hotel.update(
      trip: @trip,
      check_in: @trip.start_date,
      check_out: @trip.end_date,
      image_url: img_url_hotel || url_hotel
    )

    if @hotel.valid?
      authorize @hotel
      @trip.update(
        budgetHotel: @trip.rooms * @trip.booking.hotel.price,
        image_url: img_url_trip || url_trip
      )
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
