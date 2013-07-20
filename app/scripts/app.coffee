###
  App entry point
  a good place to define your Kanbans
###
require ['kanban'], (Kanban)->

  ## http://developer.github.com/v3/issues/

  kanban = new Kanban [ 
        ## paulmillr/ostio
        ## mitsuhiko/flask
        { url: 'https://api.github.com/repos/mitsuhiko/flask/issues?state=open', el:  '#todo' }
        ##{ 
        ##  el:  '#urgent' 
        ##  url: 'https://api.github.com/repos/mfornos/xxx/issues?state=open' 
        ##}
        ##{ 
        ##  el:  '#done' 
        ##  url: 'https://api.github.com/repos/mfornos/xxx/issues?state=closed'
        ##}
        { url: 'https://api.github.com/repos/mitsuhiko/flask/issues?state=closed', el:  '#done' } 
    ]
  
  kanban.build(
    ## oauth:
    ##  gatekeeper: (code)-> "http://localhost:9999/authenticate/#{code}"
    ## Callbacks
    onDrop: onDrop

    onAuthOk: (k)->
      $('header #close').click (e)->
        e.preventDefault()
        $('header').stop().animate({ marginTop:'-70px' },{ complete: ->
          $('#puller').show('blind')
        })
      $('#puller').mouseenter -> 
        $('header').stop().animate({ marginTop:'0px' }, { complete: -> $('#puller').hide()})

      $('#login').hide()

      $.getJSON(
        'https://api.github.com/user'
        (user)-> $('#uname').text(user.login)
      )

      $('.main').click ->
        if $('header').css('margin-top') == '0px'
          $('header #close').click() 

      $('#logout').click -> k.logout()
      $('#logout-wrap').show()
    
    beforeAuth: ->
      $('#puller').hide()
      $('.main').css('opacity', 0.25)
      $('#welcome').show('size')
      $('header').css('margin-top', '0')
      $('#login').click ->
        window.location = 'https://github.com/login/oauth/authorize?client_id=YOUR_CLIENT_ID&scope=repo'
  )

  onDrop = (ref, item, token, from, to)->
    $.ajax(
            url : "https://api.github.com/repos/mfornos/xxx/issues/#{item.get('number')}?access_token=#{token}"
            type : 'PATCH'
            data : JSON.stringify(state: if to == 'done' then 'closed' else 'open')
            success : (response, textStatus, jqXhr) -> ref.refresh()
            error : (jqXHR, textStatus, errorThrown)->
                console.log("The following error occured: #{textStatus}", errorThrown)
    )

