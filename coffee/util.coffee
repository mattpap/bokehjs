base = require("./base")
Collections = base.Collections

typeIsArray = ( value ) ->
  value and
    typeof value is 'object' and
    value instanceof Array and
    typeof value.length is 'number' and
    typeof value.splice is 'function' and
    not ( value.propertyIsEnumerable 'length' )

zip = () ->
  lengthArray = (arr.length for arr in arguments)
  length = Math.min(lengthArray...)
  for i in [0...length]
    arr[i] for arr in arguments


make_plot = (div_id, data_source, defaults, glyphspecs, xrange, yrange, {dims, tools, axes, legend, legend_name, plot_title, reference_point}) ->
  dims ?= [400, 400]
  tools ?= true
  axes ?= true
  legend ?= true
  legend_name ?= "glyph"
  plot_title ?= ""

  glyphs = []
  if not _.isArray(glyphspecs)
    glyphspecs = [glyphspecs]
  if not _.isArray(data_source)
    for glyphspec in glyphspecs
      glyph = Collections('GlyphRenderer').create({
        data_source: data_source.ref()
        glyphspec: glyphspec
        nonselection_glyphspec :
          fill_alpha : 0.1
          line_alpha : 0.1
        reference_point : reference_point
      })
      glyph.set(defaults)
      glyphs.push(glyph)
  else
    for val in zip(glyphspecs, data_source)
      [glyphspec, ds] = val
      glyph = Collections('GlyphRenderer').create({
        xdata_range : xrange.ref()
        ydata_range : yrange.ref()
        data_source: ds.ref()
        glyphspec: glyphspec
      })
      glyph.set(defaults)
      glyphs.push(glyph)

  plot_model = Collections('Plot').create(
    x_range: xrange.ref()
    y_range: yrange.ref()
    canvas_width: dims[0]
    canvas_height: dims[1]
    outer_width: dims[0]
    outer_height: dims[1]
    title: plot_title
  )
  plot_model.set(defaults)
  plot_model.add_renderers(g.ref() for g in glyphs)
  if axes
    xaxis1 = Collections('GuideRenderer').create(
      guidespec: {
        type: 'linear_axis'
        dimension: 0
        location: 'min'
        bounds: 'auto'
      }
      axis_label: 'x'
      plot: plot_model.ref()
    )
    yaxis1 = Collections('GuideRenderer').create(
      guidespec: {
        type: 'linear_axis'
        dimension: 1
        location: 'min'
        bounds: 'auto'
      }
      axis_label: 'y'
      plot: plot_model.ref()
    )
    xaxis2 = Collections('GuideRenderer').create(
      guidespec: {
        type: 'linear_axis'
        dimension: 0
        location: 'max'
        bounds: 'auto'
      }
      axis_label: 'x'
      plot: plot_model.ref()
    )
    yaxis2 = Collections('GuideRenderer').create(
      guidespec: {
        type: 'linear_axis'
        dimension: 1
        location: 'max'
        bounds: 'auto'
      }
      axis_label: 'y'
      plot: plot_model.ref()
    )
    xrule = Collections('GuideRenderer').create(
      guidespec: {
        type: 'rule'
        dimension: 0
        bounds: 'auto'
      }
      plot: plot_model.ref()
    )
    yrule = Collections('GuideRenderer').create(
      guidespec: {
        type: 'rule'
        dimension: 1
        bounds: 'auto'
      }
      plot: plot_model.ref()
    )
    plot_model.add_renderers(
      [xrule.ref(), yrule.ref(), xaxis1.ref(), yaxis1.ref(), xaxis2.ref(), yaxis2.ref()]
    )
  if tools
    pantool = Collections('PanTool').create(
      dataranges: [xrange.ref(), yrange.ref()]
      dimensions: ['width', 'height']
    )
    zoomtool = Collections('ZoomTool').create(
      dataranges: [xrange.ref(), yrange.ref()]
      dimensions: ['width', 'height']
    )
    selecttool = Collections('SelectionTool').create(
      renderers : (x.ref() for x in glyphs)
    )
    boxselectionoverlay = Collections('BoxSelectionOverlay').create(
      tool : selecttool.ref()
    )
    resizetool = Collections('ResizeTool').create()
    pstool = Collections('PreviewSaveTool').create()
    plot_tools = [pantool, zoomtool, pstool, resizetool, selecttool]
    plot_model.set_obj('tools', plot_tools)
    plot_model.add_renderers([boxselectionoverlay.ref()])
  if legend
    legends = {}
    legend_renderer = Collections("AnnotationRenderer").create(
      plot : plot_model.ref()
      annotationspec:
        type : "legend"
        orientation : "top_right"
        legends: legends
    )
    for g, idx in glyphs
      legends[legend_name + String(idx)] = [g.ref()]
    plot_model.add_renderers([legend_renderer.ref()])

  div = $(div_id)
  myrender  =  ->
    view = new plot_model.default_view(model: plot_model)
    div.append(view.$el)
  _.defer(myrender)


this.make_plot = make_plot

