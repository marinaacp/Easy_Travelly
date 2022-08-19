import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "photoInput" , "photoPreview"]

  connect() {
  //  console.log('Hello from image upload controller!')
  //  console.log(this.photoInputTarget)
  }

  previewImageOnFileSelect(event) {
    // console.log(event)
    this.displayPreview(this.photoInputTarget);
  }

  displayPreview (input) {
    if (input.files && input.files[0]) {
      const reader = new FileReader();
      reader.onload = (event) => {
        this.photoPreviewTarget.src = event.currentTarget.result;
      }
      reader.readAsDataURL(input.files[0])
      this.photoPreviewTarget.classList.remove('d-none');
    }
  }
}
