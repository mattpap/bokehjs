

define [
  "backbone",
  "common/has_properties"
], (Backbone, HasProperties) ->

  class IPythonRemoteData extends HasProperties
    type: 'IPythonRemoteData'
    defaults:
      computed_columns : []

  class IPythonRemoteDatas extends Backbone.Collection
    model: DataRange1d

  return {
    "Model": IPythonRemoteData,
    "Collection": new IPythonRemoteDatas()
  }