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

this.make_plot = (div_id, data_source, defaults, glyphspecs, xrange, yrange, tools=false, dims=[400, 400], axes=true) ->

  plot_tools = []
  if tools
    pantool = Collections('PanTool').create(
      dataranges: [xrange.ref(), yrange.ref()]
      dimensions: ['width', 'height']
    )
    zoomtool = Collections('ZoomTool').create(
      dataranges: [xrange.ref(), yrange.ref()]
      dimensions: ['width', 'height']
    )
    pstool = Collections('PreviewSaveTool').create()
    plot_tools = [pantool, zoomtool, pstool]
  glyphs = []
  if not typeIsArray(glyphspecs)
    glyphspecs = [glyphspecs]
  if not typeIsArray(data_source)
    for glyphspec in glyphspecs
      glyph = Collections('GlyphRenderer').create({
        data_source: data_source.ref()
        glyphspec: glyphspec
      })
      glyph.set(defaults)
      glyphs.push(glyph)
  else
    for val in zip(glyphspecs, data_source)
      [glyphspec, ds] = val
      glyph = Collections('GlyphRenderer').create({
        data_source: ds.ref()
        glyphspec: glyphspec
      })
      glyph.set(defaults)
      glyphs.push(glyph)
  plot_model = Collections('Plot').create(
    x_range: xrange # TODO .ref() fails?
    y_range: yrange
    canvas_width: dims[0]
    canvas_height: dims[1]
    outer_width: dims[0]
    outer_height: dims[1]
    tools: plot_tools
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
      parent: plot_model.ref()
    )
    yaxis1 = Collections('GuideRenderer').create(
      guidespec: {
        type: 'linear_axis'
        dimension: 1
        location: 'min'
        bounds: 'auto'
      }
      parent: plot_model.ref()
    )
    xaxis2 = Collections('GuideRenderer').create(
      guidespec: {
        type: 'linear_axis'
        dimension: 0
        location: 'max'
        bounds: 'auto'
      }
      parent: plot_model.ref()
    )
    yaxis2 = Collections('GuideRenderer').create(
      guidespec: {
        type: 'linear_axis'
        dimension: 1
        location: 'max'
        bounds: 'auto'
      }
      parent: plot_model.ref()
    )
    xrule = Collections('GuideRenderer').create(
      guidespec: {
        type: 'rule'
        dimension: 0
        bounds: 'auto'
      }
      parent: plot_model.ref()
    )
    yrule = Collections('GuideRenderer').create(
      guidespec: {
        type: 'rule'
        dimension: 1
        bounds: 'auto'
      }
      parent: plot_model.ref()
    )
    plot_model.add_renderers(
      [xrule.ref(), yrule.ref(), xaxis1.ref(), yaxis1.ref(), xaxis2.ref(), yaxis2.ref()]
    )
  div = $(div_id)
  myrender  =  ->
    view = new plot_model.default_view(model: plot_model)
    div.append(view.$el)
  _.defer(myrender)

