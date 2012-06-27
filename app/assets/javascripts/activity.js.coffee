# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require jquery.periodicalupdater

if $('#activities')
  Activity = {}
  Activity.poll = ->
    $.PeriodicalUpdater '/activities.json', {
      method: 'get',
      data: {modified_since: $('#activities').data().lastModified},
      autoStop: true,
      type: 'json'
    }, (activities, success, xhr, handle) ->
      if success and activities and activities.length > 0
        $('#activities').data('lastModified', activities[0].created_at)

        for activity in activities
          do (activity) ->
            $('#activities ul').append($('<li></li>').text(activity.message))

        handle.stop()
        setTimeout(Activity.poll, 3000)


  $ ->
    Activity.poll()

