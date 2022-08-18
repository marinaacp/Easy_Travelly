import { Controller } from "stimulus"

export default class extends Controller {
  static values = { hotelId: Number, bookingId: Number }
  static targets = [ "hotels" , "cards" ]

  connect() {
    console.log('Hello, Stimulus!')
  }

  selectHotel() {
    console.log(`Hotel id : ${this.hotelIdValue}.`)
    console.log(`Booking id : ${this.bookingIdValue}.`)
  }
}
