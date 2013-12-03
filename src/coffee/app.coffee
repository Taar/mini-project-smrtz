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


  class BaseView extends Backbone.View
    close: ->
      @remove()
      @unbind()
      if @onClose
        @onClose()
      return


  class AppView extends BaseView
    el: '#body'

    showView: (view) ->
      if @currentView
        @currentView.close()

      @currentView = view
      @currentView.render()

      @$el.html @currentView.$el
      return


  class QuizView extends BaseView
    className: 'question-container'

    events:
      'click #next': 'nextQuestion'

    initialize: (options) ->
      @collection = options.collection
      @collection.resetIteration()
      this

    render: ->
      @collection.fetch
        success: (collection) =>
          @nextQuestion()
      this

    nextQuestion: ->
      model = @collection.next()

      @closeCurrentView()

      if model?
        @currentView = new QuestionView
          model: model
        @currentView.render()
        @$el.html @currentView.$el
      else
        router.navigate "results",
          trigger: true,
          replace: true
      return

    closeCurrentView: ->
      if @currentView
        @currentView.close()
        @currentView = null
      return

    onClose: ->
      @closeCurrentView()
      return


  class QuestionView extends BaseView
    className: 'question'

    template: Mustache.compile $('#questionTemplate').html()

    events:
      'click .answer': 'chosenAnswer'

    initialize: ->
      @givenAnswer = false
      this

    render: ->
      @$el.html @template(@model.attributes)
      this

    chosenAnswer: (event) =>
      if not @givenAnswer
        @givenAnswer = true

        element = @$ event.target
        element.removeClass 'answer blue-style'
        element.addClass 'selected'
        element.siblings().removeClass 'answer'

        users_answer = element.data 'answer'
        @model.set
          answered: users_answer

        @questionResultView = new QuestionResultView
          model: @model

        answerModel = new AnswerModel
          id: @model.id

        answerModel.fetch
          success: (model) =>
            correct_answer = answerModel.get('answer')
            if correct_answer is users_answer
              @model.set 'result', 'correct'
            else
              @model.set 'result', 'incorrect'

            @questionResultView.render()
            @$el.append @questionResultView.$el
            return
        return

    onClose: ->
      if @questionResultView
        @questionResultView.close()
      return


  class QuestionResultView extends BaseView
    className: 'question-result'

    template: Mustache.compile $('#questionResultTemplate').html()

    render: () ->
      @$el.html @template(@model.attributes)
      this


  class StartView extends BaseView
    className: 'start'

    template: Mustache.compile $('#startTemplate').html()

    events:
      'click #start': 'startQuiz'

    render: ->
      @$el.html @template(@model.attributes)
      this

    startQuiz: ->
      router.navigate "quiz",
        trigger: true
        replace: true
      return


  class HomeView extends BaseView
    el: '#home'

    events:
      'click': 'home'

    home: (event) ->
      event.preventDefault()
      router.navigate "",
        trigger: true
        replace: true
      return


  class ResultView extends BaseView
    className: 'result'

    template: Mustache.compile $('#resultTemplate').html()

    events:
      'click .home': 'home'
      'click .again': 'again'

    initialize: (options) ->
      @collection = options.collection
      @previousResult = options.previousResult
      @results = []
      amount_correct = 0

      for model in @collection.models
        if model.get('result')
          @results.push model.attributes
          if model.get('result') is 'correct'
            amount_correct++

      @previousResult.set 'amount_correct', amount_correct
      @previousResult.set 'total_questions', @collection.length

      if amount_correct is 0
        @previousResult.set 'precent', amount_correct
      else
        @previousResult.set 'precent', amount_correct / @collection.length * 100

      this

    render: ->
      @$el.html @template(_.extend({results: @results}, @previousResult.attributes))
      this

    home: ->
      router.navigate "",
        trigger: true
        replace: true
      return

    again: ->
      router.navigate "quiz",
        trigger: true
        replace: true
      return


  class QuestionModel extends Backbone.Model
    defaults:
      id: ''
      question: ''
      answered: ''
      result: ''


  class PreviousResultModel extends Backbone.Model
    defaults:
      amount_correct: 0
      total_questions: 0
      precent: 0


  class AnswerModel extends Backbone.Model
    default:
      id: ''
      answer: ''
    fetch: (options) ->
      answers =
        1:
          answer: true
        2:
          answer: false
        3:
          answer: true
        4:
          answer: false

      id = String(@id)

      if id of answers
        answer = answers[id]
      else
        answer = null

      @set answer
      options.success this
      return


  class QuestionCollection extends Backbone.Collection
    model: QuestionModel
    url: '/questions'
    initialize: ->
      @index = 0
      this
    resetIteration: ->
      @index = 0
      this
    fetch: (options) ->
      questions = [
          'id': 1
          'question': "Tim Berners-Lee invented the World Wide Web."
        ,
          'id': 2
          'question': "Dogs are better than cats."
        ,
          'id': 3
          'question': "Winter is coming."
        ,
          'id': 4
          'question': "Internet Explorer is the most advanced browser on Earth."
      ]
      for question in questions
        @add new QuestionModel(question)
      options.success this
      return
    next: ->
      current = @index
      @index++
      return @models[current]


  class Router extends Backbone.Router
    routes:
      '': 'index'
      'quiz': 'quiz'
      'results': 'results'

    initialize: (options) ->
      @appView = new AppView()
      @previousResult = new PreviousResultModel()
      @collection = new QuestionCollection()
      homeView = new HomeView()
      this

    index: ->
      startView = new StartView
        model: @previousResult
      @appView.showView startView
      return

    quiz: ->
      @previousResult.clear()
      @collection.reset()
      quizView = new QuizView
        collection: @collection
      @appView.showView quizView
      return

    results: ->
      resultView = new ResultView
        previousResult: @previousResult
        collection: @collection
      @appView.showView resultView
      return


  router = new Router()

  Backbone.history.start()

  return
