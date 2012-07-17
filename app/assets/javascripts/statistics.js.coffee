# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require raphael
#= require ico

weekdays = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday"
]

$ ->
  $.getJSON '/statistics.json', (stats) ->
    weekly_chart_data = []
    weekly_chart_labels = []

    $.each stats.by_week, (index, item) ->
      weekly_chart_data.push(parseInt(item.games))
      weekly_chart_labels.push(
        "#{new Date(Date.parse(item.week)).toDateString()}"
      )

      null

    new Ico.BarGraph(
      $('#weekly_games_chart').get(0),
      {one: weekly_chart_data},
      {
        colours: {one: '#51a351'},
        labels: weekly_chart_labels
      }
    )

    daily_chart_data = []
    daily_chart_labels = []

    $.each stats.by_day, (index, item) ->
      daily_chart_data.push(parseInt(item.games))
      daily_chart_labels.push(
        weekdays[new Date(Date.parse(item.day)).getDay()]
      )

      null

    new Ico.BarGraph(
      $("#daily_games_chart").get(0),
      {one: daily_chart_data},
      {
        colours: {one: '#51a351'},
        labels: daily_chart_labels
      }
    )


