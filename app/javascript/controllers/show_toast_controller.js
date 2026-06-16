import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

// Connects to data-controller="show-toast"
export default class extends Controller {
  connect() {
    Toast.getOrCreateInstance(this.element).show();
  }
}
