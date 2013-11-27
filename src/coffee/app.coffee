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
  console.log $
  console.log _
  console.log Backbone
  console.log mustache
  return
