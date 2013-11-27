module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    coffee:
      compile:
        files:
          'smrtz/js/app.js': 'src/coffee/app.coffee'
    stylus:
      compile:
        files:
          'smrtz/css/base.css': 'src/stylus/base.styl'
    watch:
      scripts:
        files: ['src/coffee/*.coffee']
        tasks: ['coffee']
        options:
          spawn: false
      css:
        files: ['src/stylus/*.styl']
        tasks: ['stylus']
        options:
          spawn: false

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', [
    'coffee'
    'stylus'
    'watch'
  ]
