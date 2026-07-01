import { Controller } from "@hotwired/stimulus"
import LatchController from "./latch_controller"

// Connects to data-controller="reload-lessons-calendar"
export default class extends Controller {
  static async reload() {
    const calendarFrame = document.getElementById("lessons-calendar"),
      selectedDateValue = calendarFrame.querySelector("input[name='date']:checked")?.value;

    calendarFrame.reload();
    await LatchController.unlatching("lessons-calendar");
    calendarFrame.querySelector(`input[name='date'][value='${selectedDateValue}']`).checked = true;
    calendarFrame.querySelector("form").requestSubmit();
  }

  connect() {
    this.constructor.reload();
    this.element.remove();
  }
}
