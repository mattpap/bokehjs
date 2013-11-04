module.exports = (grunt) ->
  grunt.initConfig

    copy:
      html:
        files: [
          expand: true
          cwd: 'src'
          src: ['**/*.html']  # copy index.html from src to dist
          dest: 'build'
          filter: 'isFile'
        ]
      test:
        files: [
          expand: true
          cwd: 'test'
          src: ['**/*.html', '**/*.js']  # copy index.html from src to dist
          dest: 'build/test'
          filter: 'isFile'
        ]
      demo:
        files: [
          expand: true
          cwd: 'demo'
          src: ['**/*.html', '**/*.js']  # copy index.html from src to dist
          dest: 'build/demo'
          filter: 'isFile'
        ]
      requirejs:
        files: [
          expand: true
          cwd: 'node_modules/requirejs'
          src: ['require.js']
          dest: 'build/js'
          filter: 'isFile'
        ]
      vendor:
        files: [
          expand: true
          cwd: 'src/js/vendor'
          src: ['**/*']  # copy vendor js from src to dist
          dest: 'build/js/vendor'
          filter: 'isFile'
        ]

    clean: ['release/js/vendor', 'release/js/views', 'release/build.txt']

    less:
      development:
        options:
          concat: false
        files: [{
          expand: true,        # enable dynamic expansion
          concat: false        # do not concatenate
          cwd: 'src/less',     # src matches are relative to this path
          src: ['*.less'],     # actual pattern(s) to match
          dest: 'build/css',   # destination path prefix
          ext: '.css',         # dest filepaths will have this extension
        }]

    coffee:
      compile:
        expand: true           # enable dynamic expansion
        cwd: 'src/coffee'      # source dir for coffee files
        src: '**/*.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/js'       # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        options:
          sourceMap : true
      test_compile:
        expand: true           # enable dynamic expansion
        cwd: 'test'            # source dir for coffee files
        src: '**/*.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/test'     # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        options:
          sourceMap : true
      demo_compile:
        expand: true           # enable dynamic expansion
        cwd: 'demo'            # source dir for coffee files
        src: '**/scatter.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/demo'     # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        options:
          sourceMap : true

    requirejs:
      compile:
        options:
          almond: true
          wrap: true
          name: 'main'
          paths:
            requireLib: 'vendor/requirejs/require'
          include: ["requireLib"]
          baseUrl: 'build/js'
          mainConfigFile: 'build/js/main.js'
          fileExclusionRegExp: /^test/
          out: 'bokeh.js'

    watch:
      scripts:
        files: ['src/coffee/**/*.coffee']
        tasks: ['coffee']
        options:
          spawn: false
      demos:
        files: ['demo/coffee/**/*.coffee']
        tasks: ['coffee']
        options:
          spawn: false
      tests:
        files: ['test/coffee/**/*.coffee']
        tasks: ['coffee']
        options:
          spawn: false
      styles:
        files: ['src/less/**/*.less']
        tasks: ['less']
        options:
          spawn: false

    qunit:
      #all: ['build/test/*.html']
      all:
        options:
          urls:[
            'http://localhost:8000/test/index.html',
            'http://localhost:8000/demo/index.html',
          ]

  grunt.loadNpmTasks("grunt-contrib-coffee")
  grunt.loadNpmTasks("grunt-contrib-watch")
  grunt.loadNpmTasks("grunt-contrib-less")
  grunt.loadNpmTasks("grunt-contrib-requirejs")
  grunt.loadNpmTasks("grunt-contrib-copy")
  grunt.loadNpmTasks("grunt-contrib-clean")
  grunt.loadNpmTasks("grunt-contrib-qunit")

  grunt.registerTask("default", ["coffee", "less",      "copy", "qunit"])
  grunt.registerTask("build",   ["coffee", "less",      "copy"         ])
  grunt.registerTask("deploy",  ["build",  "requirejs", "clean"        ])

  grunt.event.on "watch", (action, filepath, target) ->
    filepath = filepath.replace('src/coffee/', '')
    grunt.config.set('coffee',
      changed:
        expand: true
        cwd: 'src/coffee'
        src: filepath
        dest: 'build/js'
        ext: '.js'
    )
    grunt.task.run('coffee:changed')