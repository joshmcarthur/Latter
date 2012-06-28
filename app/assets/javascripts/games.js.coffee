# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require jquery.infinitescroll

if $('#games').length > 0
  $('#games').infinitescroll(
    navSelector: 'div.pagination',
    nextSelector: 'div.pagination a[rel=next]',
    itemSelector: '.game',
    bufferPx: 200,
    loading: {
      img: null,
      finishedMsg: "No more games to display",
      msgText: "Loading the next set of games..."
    }
  )

