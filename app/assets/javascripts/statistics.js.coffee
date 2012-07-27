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

formatChartDate = (date_string) ->
  date = new Date(Date.parse(date_string))
  "#{date.getDate()}/#{date.getMonth() + 1}"

$ ->
  return unless window.location.pathname == "/statistics"
  $.getJSON '/statistics.json', (stats) ->
    weekly_chart_data = []
    weekly_chart_labels = []

    $.each stats.by_week, (index, item) ->
      weekly_chart_data.push(parseInt(item.games))
      weekly_chart_labels.push(formatChartDate(item.week))

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

    challenged_count_chart_data = []
    challenged_count_chart_labels = []

    $.each stats.by_challenged, (index, item) ->
      challenged_count_chart_data.push(parseInt(item[1]))
      challenged_count_chart_labels.push(item[0])

      null

    new Ico.HorizontalBarGraph(
      $('#challenged_count_chart').get(0),
      {one: challenged_count_chart_data},
      {
        colours: {one: '#51a351'},
        labels: challenged_count_chart_labels
      }
    )

    challenger_count_chart_data = []
    challenger_count_chart_labels = []

    $.each stats.by_challenger, (index, item) ->
      challenger_count_chart_data.push(parseInt(item[1]))
      challenger_count_chart_labels.push(item[0])

      null

    new Ico.HorizontalBarGraph(
      $('#challenger_count_chart').get(0),
      {one: challenger_count_chart_data},
      {
        colours: {one: '#51a351'},
        labels: challenger_count_chart_labels
      }
    )
