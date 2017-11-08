# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$( document ).on('turbolinks:load', ->
  for cb in $('.candobox input')
    $(cb).change ->
      checked = $(this).prop('checked')
      id = $(this).prop('id')
      $.ajax({
        url: "/admin/clean_state",
        type: "POST",
        data: {id: id, checked: checked},
        success: (data)->
          console.log data
          location.reload()
      });
  for cb in $('.awaybox input')
    $(cb).change ->
      checked = $(this).prop('checked')
      id = $(this).prop('id')
      console.log checked, id
      $.ajax({
        url: "/admin/away_state",
        type: "POST",
        data: {id: id, checked: checked},
        success: (data)->
          console.log data
          location.reload()
      });
)
