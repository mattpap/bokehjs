
define [
  "underscore",
], (_) ->

  locations =

    Plot:                  'common/plot'
    GMapPlot:              'common/gmap_plot'
    GridPlot:              'common/grid_plot'
    CDXPlotContext:        'common/plot_context'
    PlotContext:           'common/plot_context'
    PlotList:              'common/plot_context'

    IPythonRemoteData:     'pandas/ipython_remote_data'
    PandasPivotTable:      'pandas/pandas_pivot_table'
    PandasPlotSource:      'pandas/pandas_plot_source'

    Range1d:               'range/range1d'
    DataRange1d:           'range/data_range1d'
    FactorRange:           'range/factor_range'
    DataFactorRange:       'range/data_factor_range'

    Glyph:                 'renderer/glyph/glyph'
    LinearAxis:            'renderer/guide/linear_axis'
    DatetimeAxis:          'renderer/guide/datetime_axis'
    Grid:                  'renderer/guide/grid'
    Legend:                'renderer/annotation/legend'
    BoxSelection:          'renderer/overlay/box_selection'

    ObjectArrayDataSource: 'source/object_array_data_source'
    ColumnDataSource:      'source/column_data_source'

    PanTool:               'tools/pan_tool'
    ZoomTool:              'tools/zoom_tool'
    ResizeTool:            'tools/resize_tool'
    BoxSelectTool:         'tools/box_select_tool'
    DataRangeBoxSelectTool:'tools/data_range_box_select_tool'
    PreviewSaveTool:       'tools/preview_save_tool'
    EmbedTool:             'tools/embed_tool'

    DataSlider:            'widget/data_slider'

  mod_cache = {}

  Collections = (typename) ->

    if not locations[typename]
      throw "./base: Unknown Collection #{typename}"

    [modulename, collection] = locations[typename]

    if not mod_cache[modulename]?
      console.log("calling require", modulename)
      mod_cache[modulename] = require(modulename)

    return mod_cache[modulename][collection]

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
    "locations": locations,
    "Collections": Collections
  }