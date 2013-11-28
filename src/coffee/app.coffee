require.config
  baseUrl: '/js/lib'
  paths:
    'jquery': 'jquery-2.0.3.min'
    'underscore': 'underscore-min'
    'backbone': 'backbone-min'
    'mustache': 'mustache'
  shim:
    backbone:
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    jquery:
      exports: '$'
    underscore:
      exports: '_'
    mustache:
      exports: 'mustache'

require ['underscore', 'jquery', 'backbone', 'mustache'], (_, $, Backbone, mustache) ->

  class QuestionView extends Backbone.View
    el: '#body'
    template: Mustache.compile $('#questionTemplate').html()
    initialize: ->
      @render()
      this
    render: ->
      @$el.html @template(@model.attributes)
      this


  class StartView extends Backbone.View
    el: '#body'
    template: Mustache.compile $('#startTemplate').html()
    initialize: ->
      @render()
      this
    render: ->
      @$el.html @template(@model.attributes)
      this


  class ResultView extends Backbone.View
    initialize: ->
      return


  class QuestionModel extends Backbone.Model
    defaults:
      id: ''
      question: ''
      answer: ''
      result: ''


  class QuestionCollection extends Backbone.Collection
    model: QuestionModel


  class Router extends Backbone.Router
    routes:
      "": "index"

    index: () ->
      startView = new StartView()

  return
