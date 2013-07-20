###
  App entry point
  a good place to define your Kanbans
###
require ['kanban'], (Kanban)->

  repoUrl  = 'https://api.github.com/repos/your/repo'
  clientId = '[YOUR_CLIENT_ID]'
  scope    = 'repo'

  kanban = new Kanban [ 
        ## paulmillr/ostio
        ## mitsuhiko/flask
        
        { url: 'https://api.github.com/repos/mitsuhiko/flask/issues?state=open', el:  '#todo' }
        { url: 'https://api.github.com/repos/paulmillr/ostio/issues?state=closed', el:  '#done' }
        { url: 'https://api.github.com/repos/mfornos/humanize/issues?state=open', el:  '#urgent' } 

        
        ##{ 
        ##  el:  '#urgent' 
        ##  url: "#{repoUrl}?state=open" 
        ##}
        ##{ 
        ##  el:  '#done' 
        ##  url: "#{repoUrl}?state=closed"
        ##}
        
  ]

  timeout = ->

  oauthOptions =
    oauth:
      gatekeeper: (code)-> "http://localhost:9999/authenticate/#{code}"
      onAuthOk: (k)->
        $('header #close').show()
        $('header #close').click (e)->
          e.preventDefault()
          $('header').stop().animate({ marginTop:'-70px' },{ complete: ->
            $('#puller').show('blind')
          })
        $('#puller').mouseenter -> 
          timeout = setTimeout( 
            -> 
              $('header').stop().animate({ marginTop:'0px' }, { complete: -> $('#puller').hide()})
            , 300
          )
        $('#puller').mouseleave ->
          clearTimeout timeout

        $.getJSON(
          'https://api.github.com/user'
          (user)-> $('#uname').text(user.login)
        )

        $('.main').click ->
          if $('header').css('margin-top') == '0px'
            $('header #close').click() 

        $('.logout').click -> k.logout()
        $('#login-wrap').hide()
        $('#logout-wrap').show()
      
      beforeAuth: ->
        $('#puller').hide()
        $('#welcome').modal()
        $('header').css('margin-top', '0')
        $('.login').click ->
          window.location = "https://github.com/login/oauth/authorize?client_id=#{clientId}&scope=#{scope}"

    ## Callbacks
    onDrop: (ref, item, token, from, to)->
        $.ajax
          url : "#{repoUrl}/#{item.get('number')}"
          type : 'PATCH'
          data : JSON.stringify(state: if to == 'done' then 'closed' else 'open')
          success : -> ref.refresh()
          error : (jqXHR, textStatus, errorThrown)->
            console.log("The following error occured: #{textStatus}", errorThrown)


  ## Kick off
  kanban.build() ## kanban.build oauthOptions

