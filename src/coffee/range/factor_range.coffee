

define [
  "backbone",
  "common/has_properties"
], (Backbone, HasProperties) ->

  class FactorRange extends HasProperties
    type: 'FactorRange'

  FactorRange::defaults = _.clone(FactorRange::defaults)
  _.extend(FactorRange::defaults
    ,
      values: []
  )

  class FactorRanges extends Backbone.Collection
    model: FactorRange

  return {
    "Model": FactorRange,
    "Collection": new FactorRanges()
  }