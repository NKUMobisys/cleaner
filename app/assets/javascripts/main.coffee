# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  LuckyCard.case({
      ratio: .2
  }, ->
      c = document.getElementById("cover")
      console.log(c.toDataURL())
  );
