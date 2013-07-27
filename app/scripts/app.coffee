###
  App entry point
  a good place to define your Kanbans
###
require ['kanban', 'oauth'], (Kanban, OAuthConfig)->

  kanban = new Kanban [
        ## paulmillr/ostio
        ## mitsuhiko/flask
        
        { url: 'https://api.github.com/repos/mfornos/cushion/issues?state=open&per_page=10', el:  '#todo' }
        { url: 'https://api.github.com/repos/paulmillr/ostio/issues?state=closed&per_page=10', el:  '#done' }
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

  ## Kick off
  kanban.build()

  ## Run with OAuth
  ##opts = OAuthConfig.build
  ##  repoUrl: 'https://api.github.com/repos/your/repo/issues'
  ##  clientId: '[YOUR_CLIENT_ID]'
  ##  scope: 'public_repo'

  ##kanban.build opts

