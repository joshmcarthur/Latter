$ ->
  $('.btn-with-loading').on 'click', ->
    $(this).button('loading')

   $('.profile .badges img[rel=popover]').popover()
