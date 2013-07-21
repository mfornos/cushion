## global require
'use strict'

require.config
  paths: 
    jquery: '../bower_components/jquery/jquery'
    jqueryui: '../bower_components/jquery-ui/ui/jquery-ui'
    jqueryspin: '../bower_components/spin.js/jquery.spin'
    bootstrap: 'vendor/bootstrap'
    spin: '../bower_components/spin.js/spin'
    marked: 'vendor/marked'
    hbs: '../bower_components/hbs/hbs'
    i18nprecompile: '../bower_components/hbs/hbs/i18nprecompile'
    handlebars: '../bower_components/hbs/Handlebars'
    underscore: '../bower_components/hbs/hbs/underscore'
    backbone: '../bower_components/backbone-amd/backbone'
    json2: '../bower_components/hbs/hbs/json2'
  shim: 
    jqueryui: 'jquery'
    underscore: 
      exports: '_'
    backbone: 
      deps: [
        'underscore'
        'jquery'
      ]
      exports: 'Backbone'
    bootstrap: 
      deps: ['jquery']
      exports: 'jquery'
    marked:
      exports: 'marked'

require ['app'], (App) ->

  App

