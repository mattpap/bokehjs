module.exports = (grunt) ->
  grunt.initConfig

    copy:
      template:
        files: [
          expand: true
          cwd: 'src/template'
          src: ['**/*.html', '**/*.eco']
          dest: 'build/template'
          filter: 'isFile'
        ]
      test:
        files: [
          expand: true
          cwd: 'test'
          src: ['**/*.html', '**/*.js']
          dest: 'build/test'
          filter: 'isFile'
        ]
      demo:
        files: [
          expand: true
          cwd: 'demo'
          src: ['**/*.html', '**/*.js']
          dest: 'build/demo'
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
      src:
        expand: true           # enable dynamic expansion
        cwd: 'src/coffee'      # source dir for coffee files
        src: '**/*.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/js'       # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        options:
          sourceMap : true
      test:
        expand: true           # enable dynamic expansion
        cwd: 'test'            # source dir for coffee files
        src: '**/*.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/test'     # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        options:
          sourceMap : true
      demo:
        expand: true           # enable dynamic expansion
        cwd: 'demo/coffee'     # source dir for coffee files
        src: '**/*.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/demo/js'  # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        options:
          sourceMap : true

    # requirejs:
    #   compile:
    #     options:
    #       almond: true
    #       wrap: true
    #       name: 'main'
    #       paths:
    #         requireLib: 'vendor/requirejs/require'
    #       include: ["requireLib"]
    #       baseUrl: 'build/js'
    #       mainConfigFile: 'build/js/main.js'
    #       fileExclusionRegExp: /^test/
    #       out: 'bokeh.js'

    requirejs:
      compile:
        options:
          #optimize: "none"
          baseUrl: 'build/js'
          name: 'vendor/almond/almond'
          paths:
            jquery: "vendor/jquery/jquery"
            jquery_ui: "vendor/jquery-ui-amd/jquery-ui-1.10.0/jqueryui"
            jquery_mousewheel: "vendor/jquery-mousewheel/jquery.mousewheel"
            underscore: "vendor/underscore-amd/underscore"
            backbone: "vendor/backbone-amd/backbone"
            bootstrap: "vendor/bootstrap/dist/js/bootstrap"
          include: ['main', 'underscore']
          fileExclusionRegExp: /^test/
          out: 'bokeh.js'
          wrap: {
            startFile: 'src/start.frag',
            endFile: 'src/end.frag'
          }


    watch:
      src:
        files: ['src/coffee/**/*.coffee']
        tasks: ['coffee:compile']
        options:
          spawn: false
      demo:
        files: ['demo/coffee/**/*.coffee']
        tasks: ['coffee']
        options:
          spawn: false
      test:
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
      all:
        options:
          urls:[
            'http://localhost:8000/build/test/common_test.html']


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