import { Controller } from "stimulus"
// Flatpickr -> datepicker (form calendar)
import { initFlatpickr } from "../plugins/flatpickr";
// City selector
import { initSelect2 } from "../plugins/init_select2";

export default class extends Controller {

  connect() {
    initFlatpickr();
    initSelect2();
    $('#plus-btn-right').click(function(){
    	$('#qty_input_ten').val(parseInt($('#qty_input_ten').val()) + 1 );
    });
    $('#minus-btn-left').click(function(){
    	$('#qty_input_ten').val(parseInt($('#qty_input_ten').val()) - 1 );
    	if ($('#qty_input_ten').val() < 1) {
			$('#qty_input_ten').val(1);
		}
    });

    $('#plus-btn-right-2').click(function(){
    	$('#qty_input_ten-2').val(parseInt($('#qty_input_ten-2').val()) + 1 );
    });
    $('#minus-btn-left-2').click(function(){
    	$('#qty_input_ten-2').val(parseInt($('#qty_input_ten-2').val()) - 1 );
    	if ($('#qty_input_ten-2').val() < 1) {
			$('#qty_input_ten-2').val(1);
		}
    });

    $('#plus-budget-btn-right').click(function(){
    	$('#qty_input_hundred').val(parseInt($('#qty_input_hundred').val()) + 100 );
    });
    $('#minus-budget-btn-left').click(function(){
    	$('#qty_input_hundred').val(parseInt($('#qty_input_hundred').val()) - 100 );
    	if ($('#qty_input_hundred').val() < 1000) {
			$('#qty_input_hundred').val(1000);
		}
    });
  }
}
