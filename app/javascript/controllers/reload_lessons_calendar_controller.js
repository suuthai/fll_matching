import { Controller } from "@hotwired/stimulus"
import HomeController from "./home_controller"

// Connects to data-controller="reload-lessons-calendar"
export default class extends Controller {
  static reload() {
    HomeController.doWhileKeepingCalendarDateSelection(
      (calendarFrame) => calendarFrame.reload());
  }

  connect() {
    this.constructor.reload();
    this.element.remove();
  }
}
