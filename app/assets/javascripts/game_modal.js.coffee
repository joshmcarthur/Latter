class GameModal
  constructor: (options) ->
    @options = $.extend {
      header: 'Modal Heading'
      content: ''
      open_now: true
    }, options

    @hideOtherModals()
    @buildModal()
    @openModal() if @options.open_now

  hideOtherModals: ->
    $('.modal').modal('hide').remove()

  buildModal: ->
    @container = $("<div></div>").addClass('modal')
    header = $('<div></div>').addClass('modal-header')
    header.append $('<button></button>').attr('data-dismiss', 'modal').addClass('close').text('x')
    header.append $('<h3></h3>').text(@options.header)

    @container.append header
    body = $('<div></div>').addClass('modal-body').html(@options.content)

    @container.append body

    $('body').append @container

  openModal: ->
    @container.modal('show')

