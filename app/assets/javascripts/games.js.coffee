# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require jquery.infinitescroll

if $('#games')
  $('#games').infinitescroll(
    navSelector: 'div.navigation',
    nextSelector: 'div.navigation a[rel=next]',
    itemSelector: '#games div.game'
  )
