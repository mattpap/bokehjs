'use strict'

require.config
  paths:
    jquery: "vendor/jquery/jquery"
    jquery_ui: "vendor/jquery-ui-amd/jquery-ui-1.10.0/jqueryui"
    jquery_mousewheel: "vendor/jquery-mousewheel/jquery.mousewheel"
    underscore: "vendor/underscore-amd/underscore"
    backbone: "vendor/backbone-amd/backbone"
    bootstrap: "vendor/bootstrap/dist/js/bootstrap"

define (require, exports, module) ->
  require('common/has_properties')



