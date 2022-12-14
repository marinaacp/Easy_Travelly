// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "controllers"
import "bootstrap"
import "@fortawesome/fontawesome-free/css/all"
import 'jquery'

// import { createClient } from '@supabase/supabase-js'

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// Flatpickr -> datepicker (form calendar)
import { initFlatpickr } from "../plugins/flatpickr";
initFlatpickr();

import { initSelect2 } from "../plugins/init_select2";
document.addEventListener("turbolinks:load", function() {
  initSelect2();
});

// JS Animations on home page
import AOS from 'aos';
// ..
AOS.init();

// const supabaseUrl = 'https://yatjcrlwedlymsfwwaiz.supabase.co'
// const supabaseKey = process.env.SUPABASE_KEY
// const supabase = createClient(supabaseUrl, supabaseKey)
