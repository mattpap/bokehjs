

define [
  "underscore",
], (_) ->

  locations =
    AnnotationRenderer: ['./renderers/annotation_renderer', 'annotationrenderers']
    GlyphRenderer:      ['./renderers/glyph_renderer',      'glyphrenderers']
    GuideRenderer:      ['./renderers/guide_renderer',      'guiderenderers']

    PanTool:         ['./tools/pan_tool',          'pantools']
    ZoomTool:        ['./tools/zoom_tool',         'zoomtools']
    ResizeTool:      ['./tools/resize_tool',       'resizetools']
    SelectionTool:   ['./tools/select_tool',       'selectiontools']
    DataRangeBoxSelectionTool:   ['./tools/select_tool', 'datarangeboxselectiontools']
    PreviewSaveTool: ['./tools/preview_save_tool', 'previewsavetools']
    EmbedTool:       ['./tools/embed_tool', 'embedtools']
    DataSlider:      ['./tools/slider', 'datasliders']

    BoxSelectionOverlay: ['./overlays/boxselectionoverlay', 'boxselectionoverlays']

    ObjectArrayDataSource: ['./common/datasource', 'objectarraydatasources']
    ColumnDataSource:      ['./common/datasource', 'columndatasources']

    Range1d:         ['./common/ranges', 'range1ds']
    DataRange1d:     ['./common/ranges', 'datarange1ds']
    DataFactorRange: ['./common/ranges', 'datafactorranges']

    Plot:              ['./common/plot',         'plots']
    GMapPlot:          ['./common/gmap_plot',    'gmapplots']
    GridPlot:          ['./common/grid_plot',    'gridplots']
    CDXPlotContext:    ['./common/plot_context', 'plotcontexts']
    PlotContext:       ['./common/plot_context', 'plotcontexts']
    PlotList:          ['./common/plot_context', 'plotlists']

    DataTable: ['./widgets/table', 'datatables']

    IPythonRemoteData: ['./pandas/pandas', 'ipythonremotedatas']
    PandasPivotTable:  ['./pandas/pandas', 'pandaspivottables']
    PandasPlotSource:  ['./pandas/pandas', 'pandasplotsources']

    LinearAxis:   ['./renderers/guide/linear_axis', 'linearaxes']
    DatetimeAxis: ['./renderers/guide/datetime_axis', 'datetimeaxes']
    Grid:         ['./renderers/guide/grid', 'grids']
    Legend:       ['./renderers/annotation_renderer', 'annotationrenderers']


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