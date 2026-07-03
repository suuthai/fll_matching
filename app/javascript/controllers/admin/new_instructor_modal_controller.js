import NewRecordModalController from "../new_record_modal_controller"
import LatchController from "../latch_controller"

// Connects to data-controller="admin--new-instrcutor-modal"
export default class extends NewRecordModalController {
  async submitStart() {
    if (await super.submitStart()) {
      document.getElementById("instructors").reload();
    }
  }
}
