$ ->
  $('.btn-with-loading').live 'click', ->
    $(this).button('loading')

  $('.profile .badges img[rel=popover]').popover()

  $('#notifications_permissions', 'form.edit_player').click ->
    alert 'Clicked'

  $('#notifications_test', 'form.edit_player').click ->
    alert 'Testing'

