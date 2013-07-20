###

Stream of issues/cards/tasks

###
define ['jquery', 'backbone', 'underscore'], ($, Backbone, _)->

  class Stream
    
    issues: {}

    streamView: {}

    constructor: (@options)->

    build: =>

      loc = if _.isFunction @options.url then @options.url @options.token else @options.url
      @issues = new StreamModel [], url: loc
        
      @streamView = new StreamView collection: @issues, el: $(@options.el)
      @streamView.templates = @options.templates

      @showStream()

      ## TODO backbone-poller to sync every N minutes

    get: (cid)=>
      @issues.get(cid)

    reset: =>
      @issues.reset()
      @showStream()

    showStream: =>
      @issues.fetch(
        beforeSend: =>
          $(@streamView.el).text('Loading...')
        error: (model, e)=>
          console.log(model, e)
          $(@streamView.el).text("#{e.status} #{e.responseJSON.message}")
        success: =>
          $(@streamView.el).empty()
          @streamView.render()
      )

  class CardModel extends Backbone.Model 
    defaults : ->


  StreamModel = class StreamModel extends Backbone.Collection
    model: CardModel

  StreamView = class StreamView extends Backbone.View

    initialize: =>
      
      @collection.bind('reset', @render)

    render: =>

      @appendCard card for card in @collection.models 
        
      @updateWIP()

    appendCard: (card)->

      v  = new CardView model: card
      id = $(@el).attr('id') ## kanban section id

      require [@templates.card], (tmpl)=>
        v.template = tmpl
        $(@el).append v.render(@attach, id).el

    attach: (card, el, id)->
      t = $('#' + card.id, el)

      t.click (e)->
        ## do something on click
        e.stopPropagation()
        e.preventDefault()

      t.dblclick (e) ->
        card = $(@).closest('.card')
        body = $('div.body', card)
        if body.length 
          body.slideToggle('fast')
          $('.has-content', card).toggle()
        e.preventDefault()

      t.data('section', id)

      $('.tip', t).tooltip(container: 'body')


    updateWIP: ->
      wip = $('.wip', $(@el).parent())
      wipMax  = (parseInt wip.text(), 10)
      itemsNo = @collection.models.length 

      if wip.length and  wipMax <= itemsNo
        wip.addClass if wipMax == itemsNo then 'limit' else 'exceeded'
      else
        wip.removeClass 'exceeded limit'


  CardView = class CardView extends Backbone.View
    render: (attach, id)->
      $(@el).html @template model: @model.toJSON()
      attach(@model, @el, id)
      @
      

  Stream

