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
      exports: 'Mustache'

require ['underscore', 'jquery', 'backbone', 'mustache'], (_, $, Backbone, Mustache) ->

  class QuestionView extends Backbone.View
    el: '#body'
    template: Mustache.compile $('#questionTemplate').html()
    initialize: ->
      @collection = new QuestionCollection()
      @collection.fetch
        success: (result) =>
          console.log result
          for question in result
            console.log question
            @collection.add new QuestionModel(question)
          @model = {}
          @render()
      this
    render: ->
      @$el.html @template(@model.attributes)
      this


  class StartView extends Backbone.View
    el: '#body'
    template: Mustache.compile $('#startTemplate').html()
    events:
      'click #start': 'startQuiz'
    initialize: ->
      @render()
      this
    render: ->
      @$el.html @template()
      this
    startQuiz: ->
      questionView = new QuestionView()
      questionView.render()


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
    url: '/questions'
    sync: (method, model, options) ->
      console.log 'sync'
      questions = [
        'id': 1
        'text': "Tim Berners-Lee invented the Internet."
        'answer': true
        ,
        'id': 2
        'text': "Dogs are better than cats."
        'answer': false
        ,
        'id': 3
        'text': "Winter is coming."
        'answer': true
        ,
        'id': 4
        'text': "Internet Explorer is the most advanced browser on Earth."
        'answer': false
      ]
      options.success(questions)
      return


  class Router extends Backbone.Router
    routes:
      '': 'index'

    index: () ->
      console.log 'index'
      startView = new StartView()


  router = new Router()

  Backbone.history.start
    pushState: true

  return
