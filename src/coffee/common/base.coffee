
define [
  "underscore",
], (_) ->

  locations =
    AnnotationRenderer: ['./renderers/annotation_renderer', 'annotationrenderers']
    GlyphRenderer:      ['./renderers/glyph_renderer',      'glyphrenderers']
    GuideRenderer:      ['./renderers/guide_renderer',      'guiderenderers']
    LinearAxis:         ['./renderers/guide/linear_axis', 'linearaxes']
    DatetimeAxis:       ['./renderers/guide/datetime_axis', 'datetimeaxes']
    Grid:               ['./renderers/guide/grid', 'grids']
    Legend:             ['./renderers/annotation_renderer', 'annotationrenderers']

    PanTool:         ['./tools/pan_tool',          'pantools']
    ZoomTool:        ['./tools/zoom_tool',         'zoomtools']
    ResizeTool:      ['./tools/resize_tool',       'resizetools']
    SelectionTool:   ['./tools/select_tool',       'selectiontools']
    DataRangeBoxSelectionTool:   ['./tools/select_tool', 'datarangeboxselectiontools']
    PreviewSaveTool: ['./tools/preview_save_tool', 'previewsavetools']
    EmbedTool:       ['./tools/embed_tool', 'embedtools']

    BoxSelectionOverlay: ['./overlays/boxselectionoverlay', 'boxselectionoverlays']

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

    ObjectArrayDataSource: 'source/object_array_data_source'
    ColumnDataSource:      'source/column_data_source'

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
    jsondata = ({type : m.type, attributes :_.clone(m.attributes)} for m in models)
    jsondata = JSON.stringify(jsondata)
    url = Config.prefix + "/bokeh/bb/" + doc + "/bulkupsert"
    xhr = $.ajax(
      type : 'POST'
      url : url
      contentType: "application/json"
      data : jsondata
      header :
        client : "javascript"
    )
    xhr.done((data) ->
      load_models(data.modelspecs)
    )
    return xhr

  return {
    "locations": locations,
    "Collections": Collections
  }