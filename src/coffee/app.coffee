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

  class QuizView extends Backbone.View
    el: '#body'
    initialize: ->
      @collection = new QuestionCollection()
      @collection.fetch
        success: (collection) =>
          console.log "Success"
          console.log @collection.length
          questionView = new QuestionView
            model: @collection.next()
          @$el.html questionView.$el
      this

  class QuestionView extends Backbone.View
    className: 'question_view'
    template: Mustache.compile $('#questionTemplate').html()
    events:
      'click .answer': 'chosenAnswer'
    initialize: ->
      @givenAnswer = false
      @listenTo @model, 'change', @render
      @render()
      this
    render: ->
      @$el.html @template(@model.attributes)
      this
    chosenAnswer: (event) =>
      if !@givenAnswer
        @givenAnswer = true

        element = $(event.target)
        element.addClass 'chosen'

        result = element.data('result')
        @model.result = result
        console.log typeof @model.result
        console.log typeof @model.answer
        console.log @model.answer

        context = {}
        if @model.answer == @model.result
          context['result'] = 'Correct'
          context['result_class'] = 'correct'
        else
          context['result'] = 'Incorrect'
          context['result_class'] = 'incorrect'

        questionResultModel = new QuestionResultModel context

        questionResultView = new QuestionResultView
          model: questionResultModel
        questionResultView.render()
        @$el.append questionResultView.$el
        return


  class QuestionResultView extends Backbone.View
    className: 'result'
    template: Mustache.compile $('#questionResultTemplate').html()
    initialize: ->
      this
    render: () ->
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
      quizView = new QuizView()
      quizView.render()


  class ResultView extends Backbone.View
    initialize: ->
      return


  class QuestionModel extends Backbone.Model
    defaults:
      id: ''
      question: ''
      answer: ''
      result: ''


  class QuestionResultModel extends Backbone.Model
    defaults:
      result: ''
      result_class: ''


  class QuestionCollection extends Backbone.Collection
    model: QuestionModel
    url: '/questions'
    fetch: (options) ->
      console.log 'sync'
      questions = [
          'id': 1
          'question': "Tim Berners-Lee invented the Internet."
          'answer': true
        ,
          'id': 2
          'question': "Dogs are better than cats."
          'answer': false
        ,
          'id': 3
          'question': "Winter is coming."
          'answer': true
        ,
          'id': 4
          'question': "Internet Explorer is the most advanced browser on Earth."
          'answer': false
      ]
      for question in questions
        @add new QuestionModel(question)
        console.log question
      options.success this
      return
    next: ->
      @index = if @index then @index++ else 0
      return @models[@index]


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
