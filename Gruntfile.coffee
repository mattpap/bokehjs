module.exports = (grunt) ->
  fs = require("fs")

  # (task: String)(input: String) => Boolean
  hasChanged = (task) -> (input) ->
    cwd  = grunt.config.get("#{task}.cwd")
    dest = grunt.config.get("#{task}.dest")
    ext  = grunt.config.get("#{task}.ext")

    output = input.replace(cwd, dest)
                  .replace(/\..+$/, ext)

    if not fs.existsSync(output)
      true
    else
      fs.statSync(input).mtime > fs.statSync(output).mtime

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
          filter: hasChanged("less.development.files.0")
        }]

    coffee:
      compile:
        expand: true           # enable dynamic expansion
        cwd: 'src/coffee'      # source dir for coffee files
        src: '**/*.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/js'       # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        filter: hasChanged("coffee.compile")
        options:
          sourceMap : true
      test:
        expand: true           # enable dynamic expansion
        cwd: 'test'            # source dir for coffee files
        src: '**/*.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/test'     # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        filter: hasChanged("coffee.test")
        options:
          sourceMap : true
      demo:
        expand: true           # enable dynamic expansion
        cwd: 'demo/coffee'     # source dir for coffee files
        src: '**/*.coffee'     # traverse *.coffee files relative to cwd
        dest: 'build/demo/js'  # destination for compiled js files
        ext: '.js'             # file extension for compiled files
        filter: hasChanged("coffee.demo")
        options:
          sourceMap : true

    requirejs:
      options:
        baseUrl: 'build/js'
        name: 'vendor/almond/almond'
        paths:
          jquery: "vendor/jquery/jquery"
          jquery_ui: "vendor/jquery-ui-amd/jquery-ui-1.10.0/jqueryui"
          jquery_mousewheel: "vendor/jquery-mousewheel/jquery.mousewheel"
          underscore: "vendor/underscore-amd/underscore"
          backbone: "vendor/backbone-amd/backbone"
          bootstrap: "vendor/bootstrap/dist/js/bootstrap"
          timezone: "vendor/timezone/src/timezone"
          sprintf: "vendor/sprintf/src/sprintf"
        shim:
          sprintf:
            exports: 'sprintf'
        include: ['main', 'underscore']
        fileExclusionRegExp: /^test/
        wrap: {
          startFile: 'src/js/_start.js.frag',
          endFile: 'src/js/_end.js.frag'
        }
      dist:
        options:
          optimize: "uglify2"
          out: 'build/bokeh.min.js'
      dev:
        options:
          optimize: "none"
          out: 'build/bokeh.js'


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

  grunt.registerTask("default",    ["coffee", "less",           "copy", "qunit"])
  grunt.registerTask("build",      ["coffee", "less",           "copy"         ])
  grunt.registerTask("deploy",     ["build",  "requirejs:dist", "clean"        ])
  grunt.registerTask("devdeploy",  ["build",  "requirejs:dev",  "clean"        ])


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