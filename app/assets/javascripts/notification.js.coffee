class Notification
	constructor: (@message) ->
		@url = ""
		@title = "Latter Notification"

		@show()

	show: ->
		if window.webkitNotifications.checkPermission() == 0
			window.webkitNotifications.createNotification(@url, @title, @message).show()

Latter.Notification = Notification