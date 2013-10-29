
define [
  "./linear_axis",
  "./common/ticking"
] (LinearAxis, ticking) ->

linear_axis = require('./linear_axis')
ticking = require('../../common/ticking')

class DatetimeAxisView extends LinearAxis.View

  initialize: (attrs, options) ->
    super(attrs, options)
    @formatter = new ticking.DatetimeFormatter()

class DatetimeAxis extends LinearAxis.Model
  default_view: DatetimeAxisView

  initialize: (attrs, options)->
    super(attrs, options)

class DatetimeAxes extends Backbone.Collection
  model: DatetimeAxis

return {
    "Model": DatetimeAxis,
    "Collection": new DatetimeAxes(),
    "View": DatetimeAxisView
  }
