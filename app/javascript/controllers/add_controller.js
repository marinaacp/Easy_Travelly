import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "add", "minus" ]

  connect() {
    console.log('Hello 2');
  }

  couting(event) {
    console.log(event);
    number = 1,
    min = 1,
    max = 10;
    numberPlace = document.getElementById("trip_adults")
    this.addTarget.classList.onclick(); {
      number = number+1;
      numberPlace.innerText = number;
    }
    this.minusTarget.classList.onclick(); {
      number = number-1;
      numberPlace.innerText = number;
    }
  }
}

number++;
++number
