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

  app = {}

  class QuizView extends Backbone.View
    el: '#body'

    initialize: ->
      app.quizEvents.bind "nextQuestion", _.bind(@nextQuestion, this)
      app.collection.fetch
        success: (collection) =>
          #@nextQuestion()
          app.quizEvents.trigger "nextQuestion"
          return
      @render()
      this

    nextQuestion: ->

      if @currentView?
        @currentView.remove()

      model = app.collection.next()

      if model?
        @currentView = new QuestionView
          model: model
        @$el.html @currentView.$el
      else
        app.quizEvents.unbind "nextQuestion"
        app.router.navigate "results",
          trigger: true,
          replace: true


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

        result = element.data 'result'
        @model.set
          result: result

        context = {}
        if @model.get('answer') is result
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

    events:
      'click #next': 'triggerNextQuestion'

    template: Mustache.compile $('#questionResultTemplate').html()

    initialize: ->
      this

    render: () ->
      @$el.html @template(@model.attributes)
      this

    triggerNextQuestion: ->
      app.quizEvents.trigger "nextQuestion"
      return


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
      app.router.navigate "quiz",
        trigger: true
        replace: true


  class ResultView extends Backbone.View
    el: '#body'

    template: Mustache.compile $('#resultTemplate').html()

    initialize: ->
      console.log "Initialize"
      @render()

    render: ->
      results = (model.attributes for model in app.collection.models)
      console.log results
      @$el.html @template
        results: results
        result: 2
        total: 4
      this


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
    initialize: ->
      @index = 0
      this
    fetch: (options) ->
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
      options.success this
      return
    next: ->
      current = @index
      @index++
      return @models[current]


  app.quizEvents = _.extend {}, Backbone.Events


  class Router extends Backbone.Router
    routes:
      '': 'index'
      'quiz': 'quiz'
      'results': 'results'

    index: ->
      startView = new StartView()

    quiz: ->
      app.collection = new QuestionCollection()
      quizView = new QuizView()

    results: ->
      resultView = new ResultView()


  app.router = new Router()

  Backbone.history.start
    pushState: true

  return
