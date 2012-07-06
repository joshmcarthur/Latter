# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require raphael
#= require g.raphael-min
#= require g.bar-min

$ ->
  $.getJSON '/statistics.json', (stats) ->
    chart_data = []
    chart_labels = []

    $.each stats.all, (index, item) ->
      chart_data.push(item.games)
      chart_labels.push(item.week)

    canvas = Raphael("all_games_chart")
    canvas.barchart(10, 10, 300, 250, [chart_data], {stacked: true, type: 'soft'})
    Raphael.g.axis(85, 260, 310, null, null, 4, 2, chart_labels, "|", 0, canvas)
