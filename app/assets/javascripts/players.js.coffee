$ ->
  $('.btn-with-loading').live 'click', ->
    $(this).button('loading')

   $('.profile .badges img[rel=popover]').popover()
