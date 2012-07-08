# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require jquery.periodicalupdater

if $('#activities').length > 0
  Activity = {}
  Activity.poll = ->
    $.PeriodicalUpdater '/activities.json', {
      method: 'get',
      data: {last: if $('#activities').data() then $('#activities').data().last else null},
      autoStop: true,
      type: 'json'
    }, (activities, success, xhr, handle) ->
      if success and activities and activities.length > 0
        $('#activities').data('last', activities[0].id)

        for activity in activities
          do (activity) ->
            list_item = $('<li></li>').text(activity.message)
            list_item.append($("<span class='time_ago'></span>").text(activity.time_ago))

            $('#activities ul').append(list_item)

        handle.stop()
        setTimeout(Activity.poll, 3000)


  $ ->
    Activity.poll()

