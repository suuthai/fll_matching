import DisposableModalController from "./disposable_modal_controller"
import LatchController from "./latch_controller"
import HomeController from "./home_controller"
import { Modal } from "bootstrap"

// Connects to data-controller="new-lesson-modal"
export default class extends DisposableModalController {
  async submitStart() {
    this.element.querySelectorAll("button").forEach((button) => button.disabled = true);
    await LatchController.unlatching("create-lesson");
    this.hideModal();

    const calendarFrame = document.getElementById("lessons-calendar"),
      selectedDateValue = calendarFrame.querySelector("input[name='date']:checked")?.value;

    calendarFrame.reload();
    await LatchController.unlatching("lessons-calendar");
    calendarFrame.querySelector(`input[name='date'][value='${selectedDateValue}']`).checked = true;
    calendarFrame.querySelector("form").requestSubmit();
  }
}
