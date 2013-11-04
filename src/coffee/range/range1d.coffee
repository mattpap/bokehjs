
define [
  "underscore",
  "backbone",
  "common/has_properties"
], (_, Backbone, HasProperties) ->

  class Range1d extends HasProperties
    type: 'Range1d'
    initialize: (attrs, options) ->
      super(attrs, options)
      @register_property('min',
          () -> Math.min(@get('start'), @get('end'))
        , true)
      @add_dependencies('min', this, ['start', 'end'])
      @register_property('max',
          () ->
            Math.max(@get('start'), @get('end'))
        , true)
      @add_dependencies('max', this, ['start', 'end'])


  Range1d::defaults = _.clone(Range1d::defaults)
  _.extend(Range1d::defaults
    ,
      start: 0
      end: 1
  )

  class Range1ds extends Backbone.Collection
    model: Range1d

  return {
    "Model": Range1d,
    "Collection": new Range1ds()
  }