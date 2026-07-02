import { Controller } from "@hotwired/stimulus"
import LatchController from "./latch_controller"

// Connects to data-controller="home"
export default class extends Controller {
  connect() {
    this.changeInstructorFilter();
  }

  changeInstructorFilter() {
    this.constructor.doWhileKeepingCalendarDateSelection((calendarFrame) => {
      const dataset = calendarFrame.dataset,
        instructorId = document.getElementById("instructor-filter").value,
        path = instructorId
          ? dataset.instructorSrc.replace(":instructor_id", instructorId)
          : dataset.src,
        params = calendarFrame.src ? new URL(calendarFrame.src).searchParams : new URLSearchParams(),
        timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;

      params.set("time_zone", timeZone);
      calendarFrame.src = path + "?" + params;
    });
  }

  static async doWhileKeepingCalendarDateSelection(doIt) {
    const calendarFrame = document.getElementById("lessons-calendar"),
      selectedDateValue = calendarFrame.querySelector("input[name='date']:checked")?.value;

    if (selectedDateValue) {
      const unlatching = LatchController.unlatching("lessons-calendar");
      doIt(calendarFrame);
      await unlatching;
      calendarFrame.querySelector(`input[name='date'][value='${selectedDateValue}']`).checked = true;
      calendarFrame.querySelector("form").requestSubmit();
    } else {
      doIt(calendarFrame);
    }
  }
}
