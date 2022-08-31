import flatpickr from "flatpickr";
import rangePlugin from "flatpickr/dist/plugins/rangePlugin";

const initFlatpickr = () => {
  flatpickr(".datepicker", {
    // altInput: true,
    dateFormat: "d-m-Y"
  });
}

export { initFlatpickr };
