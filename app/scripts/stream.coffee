###

Stream of issues/cards/tasks

###
define ['jquery', 'backbone', 'underscore'], ($, Backbone, _)->

  class Stream
    
    issues: {}
    streamView: {}

    constructor: (@options)->

    build: (@kanban)->
      loc = if _.isFunction @options.url then @options.url @options.token else @options.url
      @issues = new StreamModel [], url: loc
        
      @streamView = new StreamView collection: @issues, el: $(@options.el)
      @streamView.initTemplates @options.templates
      @streamView.kanban = @kanban


      @showStream()

      ## TODO backbone-poller to sync every N minutes

    get: (cid)->
      @issues.get(cid)

    reset: ->
      @issues.reset()
      @showStream()

    showStream: ->
      @issues.fetch(
        beforeSend: =>
          $(@streamView.el).spin('large', '#fff')
        error: (model, e)=>
          console.log(model, e)
          $(@streamView.el).spin(false)
          $(@streamView.el).text("#{e.status} #{e.responseJSON.message}")
        success: =>
          $(@streamView.el).spin(false)
          $(@streamView.el).empty()
          @streamView.render()
      )

  ###
    
    Models

  ###

  class CardModel extends Backbone.Model
    initialize : ->
      @comments = new CommentsModel
      @comments.url = @.get('comments_url')
      @

  class CommentModel extends Backbone.Model
    defaults: ->

  class CommentsModel extends Backbone.Collection
    model: CommentModel
    defaults: ->

  class StreamModel extends Backbone.Collection
    model: CardModel

  ###
    
    Views

  ###

  class CommentsView extends Backbone.View
    render: ->
      for comment in @collection.models
        $(@el).append @template model: comment.toJSON()

      $('.tip', $(@el)).tooltip(container: 'body')

      @toggle()

    toggle: ->
      $(@el).slideToggle('fast') unless $(@el).is ':empty'
      @

  class StreamView extends Backbone.View
    initialize: -> @collection.bind('reset', @render)

    initTemplates: (templates)->
      require [templates.card, templates.comment], (cardTmpl, commentTmpl)=>
        @cardTemplate = cardTmpl
        @commentsTemplate = commentTmpl

    render: ->
      @appendCard card for card in @collection.models
      @updateWIP()
      @kanban.reorder($(@el))

    appendCard: (card)->
      v  = new CardView model: card
      id = $(@el).attr('id') ## kanban section id
      v.template = @cardTemplate
      v.commentsView.template = @commentsTemplate

      $(@el).append v.render(@attach, id).el

    attach: (card, el, id)->
      ## Target card
      t = $(el)
      t.data('section', id)

      t.click (e)->
        ## do something on click
        e.stopPropagation()
        e.preventDefault()

      ## Card title
      $('.title', t).click (e) ->
        cel = $(@).closest('.card')
        body = $('div.body', cel)
        if body.length
          body.slideToggle('fast')
          $('.has-content', cel).toggle()
        e.preventDefault()

      ## Comments
      $('.comments', t).click (e)->
        e.stopPropagation()
        e.preventDefault()
        card.trigger('showComments')

      ## Tooltips
      $('.tip', t).tooltip(container: 'body')

    updateWIP: ->
      wip = $('.wip', $(@el).parent())
      wipMax  = (parseInt wip.text(), 10)
      itemsNo = @collection.models.length
      wip.val(itemsNo)

      if wip.length and  wipMax <= itemsNo
        wip.addClass if wipMax == itemsNo then 'limit' else 'exceeded'
      else
        wip.removeClass 'exceeded limit'


  CardView = class CardView extends Backbone.View
    @spinOpts: { left: -20, lines: 8, length: 2, width: 2, radius: 3 }

    initialize: ->
      @commentsView = new CommentsView
      @model.bind('showComments', @showComments)

    showComments: =>
      unless @model.comments.length
        csel = $('.comments', @el)
        @model.comments.fetch(
          beforeSend: => csel.spin(CardView.spinOpts)
          error: (model, e)=>
            console.log(model, e)
            csel.spin(false)
            $('.comments-content', @el).text("#{e.status} #{e.responseJSON.message}")
          success: =>
            csel.spin(false)
            @commentsView.collection = @model.comments
            @model.comments.bind('reset', @commentsView.render)
            @commentsView.el = $('.comments-content', @el)
            @commentsView.render()
        )
      else
        @commentsView.toggle()

    render: (attach, id)->
      @el = $(@template model: @model.toJSON())
      attach(@model, @el, id)
      @
      

  Stream

