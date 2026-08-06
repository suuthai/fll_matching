import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="href-with-timezone"
export default class extends Controller {
  connect() {
    const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone,
      params = new URLSearchParams();

    params.set("time_zone", timeZone);
    this.element.href += "?" + params;
  }
}
