jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()

  $('body').noisy({
    'intensity' : 1,
    'size' : '200',
    'opacity' : 0.053,
    'monochrome' : false
  })
