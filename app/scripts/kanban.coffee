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

    streams: {}
    token: {}

    defaultDesc: 
      { 
        templates: 
          card: 'hbs!template/card'
      }
    options:
      {
        selector: '.drag-zone'
        placeholder: 'card-holder'

        ## Callbacks
        onDrop: (ref, item, token, from, to, stream, event, ui, element)->
      }

    constructor: (@descriptors)->
      $.ajaxSetup(
        cache: false
        headers:
          Accept: 'application/json'
          'Content-Type': 'application/json'
      )

    build: (opts)=> 
      $.extend(@options, opts)
      if @options.oauth then @oauthSupport() else @init()

    refresh: ->
      stream.reset() for stream in @streams

    buildStream: (desc)->

      desc.token = @token
      stream = new Stream($.extend({}, @defaultDesc, desc))
      @streams[stream.options.el] = stream
      stream.build()

    oauthSupport: ->

      $('#auth-tools').show()

      # TODO check if cookie is still valid
      @token = Cookies.read('access_token')
      return @authOk() if @token

      m = window.location.href.match(/\?code=(.*)/)
      if m
        $.getJSON(@options.oauth.gatekeeper(m[1]), (data)=>
          if data.token
            Cookies.write('access_token', data.token)
            toUrl = (l) -> "#{l.protocol}//#{l.hostname}:#{l.port}#{l.pathname}"
            window.location = toUrl window.location
        ).error =>
          console.log("Make sure that gatekeeper is running at #{@options.oauth.gatekeeper('code')}")
      else
        @options.beforeAuth()

    authOk: ->
      $.ajaxSetup( 
        headers:
          Authorization: "token #{@token}"
          Accept: 'application/json'
          'Content-Type': 'application/json'
      )
      @options.onAuthOk(@)
      @init()

    logout: ->
      Cookies.erase('access_token')
      window.location = window.location

    init: ->
      $(@options.selector).sortable(
        connectWith: @options.selector
        delay: 150 ## Needed to prevent accidental drag when trying to select
        opacity: 0.6
        cursor: 'move'
        ## handle: '.ui-selected .dragger'
        placeholder: @options.placeholder
      ).droppable(drop: (event, ui) =>
        
          to = $(event.target).attr('id')
          from = $('.card', ui.draggable).data('section')
          s = @streams['#' + from]

          element = $(event.toElement)
          unless element.hasClass 'card'
            element = element.closest('.card')

          item = s.get(element.attr('id'))

          @options.onDrop(@, item, @token, s, from, to, event, ui, element)

      ).disableSelection()

      @buildStream(desc) for desc in @descriptors


  class Cookies

    @read: (name)->
      ca = document.cookie.split(';')
      for p in ca
        kv = p.split('=')
        return kv[1] if kv[0] is name
   
    @write: (name, value, expire = '2015-01-01 12:00:00')->
      today = new Date()
      expires = new Date(expire)      
      document.cookie = "#{name}=#{escape(value)};expires=#{expires.toGMTString()}"

    @erase: (name)->
      Cookies.write(name, '', '1970-01-01 12:00:00')
   

  Kanban
