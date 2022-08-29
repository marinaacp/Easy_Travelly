import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "form" ]

  connect() {
    console.log('Hello 2');
  }

  couting(event) {
    console.log(event);
  }
}
