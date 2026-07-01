import DisposableModalController from "./disposable_modal_controller"
import LatchController from "./latch_controller"
import ReloadLessonsCalendarController from "./reload_lessons_calendar_controller"
import { Modal } from "bootstrap"

// Connects to data-controller="new-lesson-modal"
export default class extends DisposableModalController {
  async submitStart() {
    this.element.querySelectorAll("button").forEach((button) => button.disabled = true);
    await LatchController.unlatching("create-lesson");
    this.hideModal();
    ReloadLessonsCalendarController.reload();
  }
}
