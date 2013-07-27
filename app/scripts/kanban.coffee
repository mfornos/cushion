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
define ['stream','jquery', 'persistence', 'jqueryui', 'jqueryspin', 'bootstrap'], (Stream, $, CookieStore)->

  class Kanban

    streams: {}
    token: {}

    defaultDesc:
      {
        templates:
          card: 'hbs!template/card'
          comment: 'hbs!template/comment'
      }
    options:
      {
        selector: '.drag-zone'
        placeholder: 'card-holder'

        ## Defaults to cookie based storage
        store: new CookieStore

        ## Callbacks
        onDrop: (ref, item, token, from, to, stream, event, ui, element)->
      }

    constructor: (@descriptors)->
      $.ajaxSetup
        cache: false
        headers:
          Accept: 'application/json'
          'Content-Type': 'application/json'

    build: (opts)=>
      $.extend(@options, opts)
      if @options.oauth then @oauthSupport() else @init()

    refresh: ->
      stream.reset() for stream in @streams

    buildStream: (desc)->
      desc.token = @token
      stream = new Stream($.extend({}, @defaultDesc, desc))
      @streams[stream.options.el] = stream
      stream.build(@)

    oauthSupport: ->
      $('#auth-tools').show()

      console.log(@options.store)
      @token = @options.store.read('access_token')
      return @authOk() if @token

      m = window.location.href.match(/\?code=(.*)/)
      if m
        $.getJSON(@options.oauth.gatekeeper(m[1]), (data)=>
          if data.token
            @options.store.save('access_token', data.token)
            toUrl = (l) -> "#{l.protocol}//#{l.hostname}:#{l.port}#{l.pathname}"
            window.location = toUrl window.location
        ).error =>
          console.log("Make sure that gatekeeper is running at #{@options.oauth.gatekeeper('code')}")
      else
        @options.oauth.beforeAuth()

    authOk: ->
      $.ajaxSetup
        cache: false
        headers:
          Authorization: "token #{@token}"
          Accept: 'application/json'
          'Content-Type': 'application/json'

      @options.oauth.onAuthOk(@)
      @init()

    logout: ->
      @options.store.remove('access_token')
      window.location = window.location

    reorder: (el)-> @options.store.onReorder el

    init: ->
      $(@options.selector).sortable(
        connectWith: @options.selector
        delay: 150 ## Needed to prevent accidental drag when trying to select
        opacity: 0.6
        cursor: 'move'
        ## handle: '.ui-selected .dragger'
        placeholder: @options.placeholder

        update: (event, ui)-> @options.store.onUpdate($(@), event, ui)
      ).droppable(drop: (event, ui)=>

        to = $(event.target).attr('id')
        from = $(ui.draggable).data('section')
        s = @streams["##{from}"]

        element = $(event.toElement)
        unless element.hasClass 'card'
          element = element.closest('.card')

        item = s.get(element.attr('id'))

        @options.onDrop(@, item, @token, from, to, s, event, ui, element)

      ).disableSelection()

      @buildStream(desc) for desc in @descriptors
   

  Kanban
