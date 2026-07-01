import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// Connects to data-controller="disposable-modal"
export default class extends Controller {
  #modal;

  connect() {
    this.#modal = new Modal(this.element);

    this.element.addEventListener("hidden.bs.modal", () => {
      this.#modal.dispose();
      this.element.remove();
    });

    this.#modal.show();
  }

  hideModal() {
    this.#modal.hide();
  }
}
