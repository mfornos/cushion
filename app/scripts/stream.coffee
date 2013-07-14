###

Stream of issues/cards/tasks

###
define ['jquery', 'backbone', 'handlebars'], ($, Backbone)->

  class Stream
    
    @issues

    @streamView

    constructor: (@options)->

    build: =>
      @issues = new StreamModel [], url: @options.url
        
      @streamView = new StreamView collection: @issues, el: $(@options.el)
      @streamView.templates = @options.templates

      @showStream()

      ## TODO backbone-poller to sync every N minutes

    get: (cid) =>
      @issues.get(cid)

    reset: =>
      @issues.reset()
      @showStream()

    showStream: =>
      @issues.fetch().complete => @streamView.render()


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
        $(@).toggleClass 'ui-selected'
        e.stopPropagation()
        e.preventDefault()

      t.dblclick (e) ->
        body = $('div.body', $(@))
        if body.length then body.slideToggle('fast')
        e.preventDefault()

      t.data('section', id)


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

