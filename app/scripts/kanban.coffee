###

Kanban

Usage:

  kanban = new Kanban [
    {
      url: 'https://api.github.com/repos/user/project/issues?state=open'
      el:  '#todo'
    }
    {
      url: 'https://api.github.com/repos/user/project/issues?state=closed'
      el:  '#done'
    }
  ]

  kanban.build()

###
define ['stream','jquery', 'jqueryui', 'bootstrap'], (Stream, $)->

  class Kanban

    @streams = {}
    @defaultDesc = 
      { 
        templates: 
          card: 'hbs!template/card'
      }

    constructor: (@descriptors)->

    build: (@options = {
              selector: '.drag-zone'
              placeholder: 'card-holder'

              ## Called when a card is dropped
              onDrop: (item, stream, from, to, event, ui, element)->
    })->
      
      @init()
      @buildStream(desc) for desc in @descriptors

    buildStream: (desc)->

      mdesc = $.extend({}, Kanban.defaultDesc, desc)
      stream = new Stream(mdesc)
      Kanban.streams[mdesc.el] = stream
      stream.build()

    init: ->

      $(@options.selector).sortable(
        connectWith: @options.selector
        delay: 150 ## Needed to prevent accidental drag when trying to select
        opacity: 0.6
        cursor: 'move'
        ##handle: ".dragger",
        placeholder: @options.placeholder
      ).droppable(drop: ( event, ui ) =>

          to = $(event.target).attr('id')
          from = $('.card', ui.draggable).data('section')
          s = Kanban.streams['#' + from]

          element = $(event.toElement)
          unless element.hasClass 'card'
            element = element.closest('.card')

          i = s.get(element.attr('id'))
          @options.onDrop(i, s, from, to, event, ui, element)

          ## console.log(i, element.attr('id'), element, element.attr('id'), event, to, from)

          ## PATCH /repos/:owner/:repo/issues/:number
          ##console.log(i.number, to)
          ## on success s.reset()

      ).disableSelection()

      @prepareDoc()

    prepareDoc: ->
      opts = @options
      $(document).click -> $('.ui-selected').removeClass('ui-selected')

 
  Kanban
