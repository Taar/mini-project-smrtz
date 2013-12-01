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
      console.log "QuizView initialize"
      app.quizEvents.unbind "nextQuestion"
      app.quizEvents.bind "nextQuestion", _.bind(@nextQuestion, this)
      app.collection.fetch
        success: (collection) =>
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
        element.removeClass 'answer blue-style'
        element.addClass 'selected'

        result = element.data 'result'
        @model.set
          result: result

        context = {}
        if @model.get('answer') is result
          @model.set 'status', 'correct'
        else
          @model.set 'status', 'incorrect'

        questionResultView = new QuestionResultView
          model: @model
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
      @$el.html @template(app.previousResult.attributes)
      this

    startQuiz: ->
      app.router.navigate "quiz",
        trigger: true
        replace: true


  class HomeView extends Backbone.View
    el: '#home'
    events:
      'click': 'home'
    home: (event) ->
      event.preventDefault()
      app.router.navigate "",
        trigger: true
        replace: true


  class ResultView extends Backbone.View
    el: '#body'

    template: Mustache.compile $('#resultTemplate').html()

    events:
      'click .home': 'home'
      'click .again': 'again'

    initialize: ->
      console.log "Initialize"
      @render()

    render: ->
      results = []
      amount_correct = 0

      for model in app.collection.models
        results.push model.attributes
        if model.get('status') is 'correct'
          amount_correct++

      app.previousResult.set 'amount_correct', amount_correct
      app.previousResult.set 'total_questions', app.collection.length
      app.previousResult.set 'precent', amount_correct / app.collection.length * 100

      @$el.html @template(_.extend { results: results }, app.previousResult.attributes)
      this

    home: ->
      app.router.navigate "",
        trigger: true
        replace: true

    again: ->
      app.router.navigate "quiz",
        trigger: true
        replace: true


  class QuestionModel extends Backbone.Model
    defaults:
      id: ''
      question: ''
      answer: ''
      result: ''
      status: ''


  class PreviousResultModel extends Backbone.Model
    defaults:
      amount_correct: ''
      total_questions: ''
      precent: ''


  class QuestionCollection extends Backbone.Collection
    model: QuestionModel
    url: '/questions'
    initialize: ->
      console.log "QuestionCollection initialize"
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
      console.log current
      console.log @index
      current = @index
      @index++
      return @models[current]


  app.previousResult = new PreviousResultModel()

  app.quizEvents = _.extend {}, Backbone.Events

  homeView = new HomeView()


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
