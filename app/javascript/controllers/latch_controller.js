import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

const resolveFunctionsOfEachLatch = {};

// Connects to data-controller="latch"
export default class extends Controller {

  static unlatching(latchName) {
    return new Promise((resolve) => {
      (resolveFunctionsOfEachLatch[latchName]
        || (resolveFunctionsOfEachLatch[latchName] = [])).push(resolve);
    });
  }

  connect() {
    const { latchName, latchValue } = this.element.dataset,
      functions = resolveFunctionsOfEachLatch[latchName] || [];

    for (const resolve of functions) {
      resolve(latchValue);
    }

    functions.length = 0;
    this.element.remove();
  }
}
