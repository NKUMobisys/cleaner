# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

  pre_cleaner = $("#card").html()
  $("#card").html("")
  LuckyCard.case({
      ratio: .01
  }, (type)->
      if type=="move"
        if pre_cleaner
          $("#card").html(pre_cleaner)
          pre_cleaner = null

      if type=="ratio"
        c = document.getElementById("cover")
        # console.log(c.toDataURL())
        ch_id = $('#card').attr('ch-id')
        console.log ch_id
        $.ajax({
          url: "/lucky_card",
          type: "POST",
          data: {scratch: c.toDataURL(), clean_history: ch_id},
          success: ->
        });
  );
