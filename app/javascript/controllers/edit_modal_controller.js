import DisposableModalController from "./disposable_modal_controller"
import LatchController from "./latch_controller"
import ReloadLessonsCalendarController from "./reload_lessons_calendar_controller"
import { Modal } from "bootstrap"

// Connects to data-controller="edit-modal"
export default class extends DisposableModalController {
  connect() {
    super.connect();

    this.element.addEventListener("shown.bs.modal", () => {
      this.element.querySelector("[autofocus]")?.focus();
    });
  }

  async submitStart() {
    this.element.classList.add("submitting");
    this.element.querySelectorAll("button").forEach((button) => button.disabled = true);

    if ((await LatchController.unlatching("update")) != "error") {
      this.hideModal();
      document.getElementById(this.element.dataset.recordsFrame)?.reload();
      return true;
    } else {
      this.element.classList.remove("submitting");
      this.element.querySelectorAll("button").forEach((button) => button.disabled = false);
      return false;
    }
  }
}