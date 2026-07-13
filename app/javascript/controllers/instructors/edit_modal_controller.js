import EditModalController from "../edit_modal_controller"

// Connects to data-controller="instructors--edit-modal"
export default class extends EditModalController {

  connect() {
    super.connect();

    const instructableLanguagesFieldSet = document.getElementById("instructable-languages"),
      checkboxes = [ ...instructableLanguagesFieldSet.querySelectorAll("input[type='checkbox']") ],
      validateCheckboxes = () =>
        checkboxes[0].setCustomValidity(checkboxes.every((checkbox) => !checkbox.checked)
          ? instructableLanguagesFieldSet.querySelector(".constraint-message").textContent
          : "");

    instructableLanguagesFieldSet.addEventListener("change", validateCheckboxes);
    validateCheckboxes();
  }

}
