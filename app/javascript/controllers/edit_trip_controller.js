import { Controller } from "stimulus"
import { csrfToken } from "@rails/ujs"

export default class extends Controller {
  static targets = [ "form", "name" ]

  connect() {
    console.log('Hello, Stimulus!')
  }

  edit() {
    this.nameTarget.classList.toggle('d-none')
    this.formTarget.classList.toggle('d-none')
  }

  update(event) {
    event.preventDefault()
    console.log('inside update')

    fetch(this.formTarget.action, {
      method: "PATCH",
      headers: { "Accept": "application/json", "X-CSRF-Token": csrfToken() },
      body: new FormData(this.formTarget)
    })
      .then(response => response.json())
      .then((data) => {
        if (data.inserted_item) {
          this.formTarget.classList.toggle('d-none')
          this.nameTarget.classList.toggle('d-none')
          this.nameTarget.innerHTML = data.inserted_item
        }
        this.formTarget.outerHTML = data.form
      })
  }
}
