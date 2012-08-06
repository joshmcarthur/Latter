$ ->
  $('.btn-with-loading').live 'click', ->
    $(this).button('loading')

  $('.profile .badges img[rel=popover]').popover()

  $('#notifications_permissions', 'form.edit_player').click ->
    if window.webkitNotifications.checkPermission() == 0
      # Permission allowed
      hideNotificationButton($(this))
    else
      button = $(this)
      window.webkitNotifications.requestPermission ->
        if window.webkitNotifications.checkPermission() == 0
          hideNotificationButton(button)

  hideNotificationButton = (button) ->
    button.text('Notifications are configured in your browser')
    button.attr('disabled', 'disabled')


  $("#notifications_permissions", "form.edit_player").trigger('click')

  $('#notifications_test', 'form.edit_player').click ->
    new Latter.Notification("A Test notification from Latter!")

  $('#player_wants_javascript_notifications', 'form.edit_player').click ->
    toggleWantsJavascriptNotifications($(this))



  toggleWantsJavascriptNotifications = (checkbox) ->
    if checkbox.is(':checked')
      $('#javascript_notification_config').slideDown 300, ->
        if window.webkitNotifications
          $('.supported', $(this)).show()
          $('.unsupported', $(this)).hide()
        else
          $('.unsupported', $(this)).show()
          $('.supported', $(this)).hide()
    else
      $('#javascript_notification_config').slideUp()

  toggleWantsJavascriptNotifications($('#player_wants_javascript_notifications', 'form.edit_player'))




