
define [
  "underscore",
  "require",
  # "common/plot",
  # "common/gmap_plot",
  # "common/grid_plot",
  # "common/plot_context",
  # "pandas/ipython_remote_data",
  # "pandas/pandas_pivot_table",
  # "pandas/pandas_plot_source",
  # "range/range1d",
  # "range/data_range1d",
  # "range/factor_range",
  # "range/data_factor_range",
  # "renderer/glyph/glyph",
  # "renderer/guide/linear_axis",
  # "renderer/guide/datetime_axis",
  # "renderer/guide/grid",
  # "renderer/annotation/legend",
  # "renderer/overlay/box_selection",
  "source/object_array_data_source",
  "source/column_data_source",
  # "tool/pan_tool",
  # "tool/zoom_tool",
  # "tool/resize_tool",
  # "tool/box_select_tool",
  # "tool/data_range_box_select_tool",
  # "tool/preview_save_tool",
  # "tool/embed_tool",
  # "widget/data_slider",
], (_, require) ->

  build_views = (view_storage, view_models, options, view_types=[]) ->
    # ## function: build_views
    # convenience function for creating a bunch of views from a spec
    # and storing them in a dictionary keyed off of model id.
    # views are automatically passed the model that they represent

    # ####Parameters
    # * mainmodel: model which is constructing the views, this is used to resolve
    #   specs into other model objects
    # * view_storage: where you want the new views stored.  this is a dictionary
    #   views will be keyed by the id of the underlying model
    # * view_specs: list of view specs.  view specs are continuum references, with
    #   a typename and an id.  you can also pass options you want to feed into
    #   the views constructor here, as an 'options' field in the dict
    # * options: any additional option to be used in the construction of views
    # * view_option: array, optional view specific options passed in to the construction of the view
    "use strict";
    created_views = []
    #debugger
    try
      newmodels = _.filter(view_models, (x) -> return not _.has(view_storage, x.id))
    catch error
      debugger
      console.log(error)
      throw error
    for model, i_model in newmodels
      view_specific_option = _.extend({}, options, {'model': model})
      try
        if i_model < view_types.length
          view_storage[model.id] = new view_types[i_model](view_specific_option)
        else
          view_storage[model.id] = new model.default_view(view_specific_option)
      catch error
        console.log("error on model of", model, error)
        throw error
      created_views.push(view_storage[model.id])
    to_remove = _.difference(_.keys(view_storage), _.pluck(view_models, 'id'))
    for key in to_remove
      view_storage[key].remove()
      delete view_storage[key]
    return created_views

  locations =

    Plot:                   'common/plot'
    GMapPlot:               'common/gmap_plot'
    GridPlot:               'common/grid_plot'
    CDXPlotContext:         'common/plot_context'
    PlotContext:            'common/plot_context'
    PlotList:               'common/plot_context'

    IPythonRemoteData:      'pandas/ipython_remote_data'
    PandasPivotTable:       'pandas/pandas_pivot_table'
    PandasPlotSource:       'pandas/pandas_plot_source'

    Range1d:                'range/range1d'
    DataRange1d:            'range/data_range1d'
    FactorRange:            'range/factor_range'
    DataFactorRange:        'range/data_factor_range'

    Glyph:                  'renderer/glyph/glyph'
    LinearAxis:             'renderer/guide/linear_axis'
    DatetimeAxis:           'renderer/guide/datetime_axis'
    Grid:                   'renderer/guide/grid'
    Legend:                 'renderer/annotation/legend'
    BoxSelection:           'renderer/overlay/box_selection'

    ObjectArrayDataSource:  'source/object_array_data_source'
    ColumnDataSource:       'source/column_data_source'

    PanTool:                'tools/pan_tool'
    ZoomTool:               'tools/zoom_tool'
    ResizeTool:             'tools/resize_tool'
    BoxSelectTool:          'tools/box_select_tool'
    DataRangeBoxSelectTool: 'tools/data_range_box_select_tool'
    PreviewSaveTool:        'tools/preview_save_tool'
    EmbedTool:              'tools/embed_tool'

    DataSlider:             'widget/data_slider'

  mod_cache = {}

  # for mod in _.values(locations)
  #   console.log "FOO", mod
  #   require(mod)

  Collections = (typename) ->

    if not locations[typename]
      throw "./base: Unknown Collection #{typename}"

    modulename = locations[typename]

    if not mod_cache[modulename]?
      console.log("calling require", modulename)
      mod_cache[modulename] = require(modulename)

    return mod_cache[modulename].Collection

  Collections.bulksave = (models) ->
    ##FIXME:hack
    doc = models[0].get('doc')
    jsondata = ({type: m.type, attributes:_.clone(m.attributes)} for m in models)
    jsondata = JSON.stringify(jsondata)
    url = Config.prefix + "/bokeh/bb/" + doc + "/bulkupsert"
    xhr = $.ajax(
      type: 'POST'
      url: url
      contentType: "application/json"
      data: jsondata
      header:
        client: "javascript"
    )
    xhr.done((data) ->
      load_models(data.modelspecs)
    )
    return xhr

  return {
    "build_views": build_views,
    "locations": locations,
    "Collections": Collections
  }