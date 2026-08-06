import EditModalController from "../edit_modal_controller"

// Connects to data-controller="instructors--edit-modal"
export default class extends EditModalController {

  connect() {
    super.connect();

    const validateAllCheckboxes = [ "instructable-languages", "lesson-slots" ].reduce((validatePrevious, fieldSetId) => {
      const fieldSet = document.getElementById(fieldSetId),
        checkboxes = [ ...fieldSet.querySelectorAll("input[type='checkbox']") ],
        validateThis = () => {
          checkboxes[0].setCustomValidity(checkboxes.every((checkbox) => !checkbox.checked)
            ? fieldSet.querySelector(".constraint-message").textContent
            : "");
        };

      fieldSet.addEventListener("change", validateThis);
      return () => validatePrevious(), validateThis();
    }, () => {});

    validateAllCheckboxes();
  }

}
