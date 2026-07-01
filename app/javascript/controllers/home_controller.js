import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  connect() {
    const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone,
      params = new URLSearchParams();
    params.set("time_zone", timeZone);
    const turboFrame = document.getElementById("lessons-calendar");
    turboFrame.src = turboFrame.dataset.src + "?" + params;
  }
}
