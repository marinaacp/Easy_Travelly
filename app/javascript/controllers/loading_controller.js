import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "form", "circles" ]

  connect() {
    console.log('Hello, Stimulus!');
  }

  loader(event) {
    console.log(event);
    this.formTarget.classList.toggle("d-none");
    this.circlesTarget.classList.toggle("d-none");
  }
}
