import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// Connects to data-controller="disposable-modal"
export default class extends Controller {
  #modal;

  connect() {

    // ブラウザが出力する 'Blocked aria-hidden on an element because...' という警告への対処。
    // aria-hidden="true" が設定された要素の中にフォーカスが残っていると、この警告が表示される。
    // aria-hidden="true" と一緒に inert というHTML属性を使用すると、警告が出なくなる。
    // https://developer.mozilla.org/ja/docs/Web/HTML/Reference/Global_attributes/inert
    this.element.addEventListener("hide.bs.modal", () => {
      this.element.inert = true;
    });

    this.element.addEventListener("hidden.bs.modal", () => {
      this.#modal.dispose();
      this.element.remove();
    });

    this.#modal = new Modal(this.element);
    this.#modal.show();
  }

  hideModal() {
    this.#modal.hide();
  }
}
