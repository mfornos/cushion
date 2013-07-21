define ['jquery'], ($)->

  OAuthConfig = class OAuthConfig
    @timeout: ->

    @build: (o) ->
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
            OAuthConfig.timeout = setTimeout( 
              -> 
                $('header').stop().animate({ marginTop:'0px' }, { complete: -> $('#puller').hide()})
              , 300
            )
          $('#puller').mouseleave ->
            clearTimeout OAuthConfig.timeout

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
            window.location = "https://github.com/login/oauth/authorize?client_id=#{o.clientId}&scope=#{o.scope}"

      ## Callbacks
      onDrop: (ref, item, token, from, to)->
          $.ajax
            url : "#{o.repoUrl}/#{item.get('number')}"
            type : 'PATCH'
            data : JSON.stringify(state: if to == 'done' then 'closed' else 'open')
            success : -> ref.refresh()
            error : (jqXHR, textStatus, errorThrown)->
              console.log("The following error occured: #{textStatus}", errorThrown)
  
