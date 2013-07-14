###
  App entry point
  a good place to define your Kanbans
###
require ['kanban'], (Kanban)->

  ## http://developer.github.com/v3/issues/
  
  kanban = new Kanban [ 
        ## paulmillr/ostio
        ## mitsuhiko/flask
        { url: 'https://api.github.com/repos/paulmillr/ostio/issues?state=open', el:  '#todo' }
        { url: 'https://api.github.com/repos/mfornos/humanize/issues?state=open', el:  '#urgent' }
        { url: 'https://api.github.com/repos/paulmillr/ostio/issues?state=closed', el:  '#done' } 
    ]

  kanban.build()
