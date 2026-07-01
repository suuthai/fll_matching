import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

// Connects to data-controller="disposable-toast"
export default class extends Controller {
  connect() {
    const toast = Toast.getOrCreateInstance(this.element);

    this.element.addEventListener("hidden.bs.toast", () => {
      toast.dispose();
      this.element.remove();
    });

    toast.show();
  }
}
