

require [
  "underscore",
  #"common/base",
  "common/random",
  "common/plot",
  "range/range1d",
  "renderer/glyph/glyph_factory",
  "renderer/guide/linear_axis",
  "renderer/guide/grid",
  "renderer/overlay/box_selection"
  "tool/pan_tool",
  "tool/zoom_tool",
  "tool/box_select_tool",
  "tool/preview_save_tool",
  "tool/resize_tool",
  "source/column_data_source"
], (_, Random, Plot, Range1d, GlyphFactory, LinearAxis, Grid, BoxSelection, PanTool, ZoomTool, BoxSelectTool, PreviewSaveTool, ResizeTool, ColumnDataSource) ->

  #base = require('common/base')
  #Collections = base.Collections

  make_glyph_plot = (
    data_source, defaults, glyphspecs, xrange, yrange,
    {dims, tools, axes, legend, legend_name, plot_title, reference_point}
  ) ->

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
        glyph = GlyphFactory.Collection.create({
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
        glyph = GlyphFactory.Collection.create({
          xdata_range : xrange.ref()
          ydata_range : yrange.ref()
          data_source: ds.ref()
          glyphspec: glyphspec
        })
        glyph.set(defaults)
        glyphs.push(glyph)

    plot_model = Plot.Collection.create(
      x_range: xrange.ref()
      y_range: yrange.ref()
      canvas_width: dims[0]
      canvas_height: dims[1]
      outer_width: dims[0]
      outer_height: dims[1]
      title: plot_title)

    plot_model.set(defaults)
    plot_model.add_renderers(g.ref() for g in glyphs)
    if axes
      xaxis1 = LinearAxis.Collection.create(
        dimension: 0
        axis_label: 'x'
        plot: plot_model.ref()
      )
      yaxis1 = LinearAxis.Collection.create(
        dimension: 1
        axis_label: 'y'
        plot: plot_model.ref()
      )
      xaxis2 = LinearAxis.Collection.create(
        dimension: 0
        location: 'max'
        plot: plot_model.ref()
      )
      yaxis2 = LinearAxis.Collection.create(
        dimension: 1
        location: 'max'
        plot: plot_model.ref()
      )
      xgrid = Grid.Collection.create(
        dimension: 0
        plot: plot_model.ref()
      )
      ygrid = Grid.Collection.create(
        dimension: 1
        plot: plot_model.ref()
      )
      plot_model.add_renderers(
        [xgrid.ref(), ygrid.ref(), xaxis1.ref(), yaxis1.ref(), xaxis2.ref(), yaxis2.ref()]
      )
    if tools
      pantool = PanTool.Collection.create(
        dataranges: [xrange.ref(), yrange.ref()]
        dimensions: ['width', 'height']
      )
      zoomtool = ZoomTool.Collection.create(
        dataranges: [xrange.ref(), yrange.ref()]
        dimensions: ['width', 'height']
      )
      selecttool = BoxSelectTool.Collection.create(
        renderers : (x.ref() for x in glyphs)
      )
      boxselectionoverlay = BoxSelection.Collection.create(
        tool : selecttool.ref()
      )
      resizetool = ResizeTool.Collection.create()
      pstool = PreviewSaveTool.Collection.create()
      plot_tools = [pantool, zoomtool, pstool, resizetool, selecttool]
      plot_model.set_obj('tools', plot_tools)
      plot_model.add_renderers([boxselectionoverlay.ref()])
    # if legend
    #   legends = {}
    #   legend_renderer = Collections("AnnotationRenderer").create(
    #     plot : plot_model.ref()
    #     annotationspec:
    #       type : "legend"
    #       orientation : "top_right"
    #       legends: legends
    #   )
    #   for g, idx in glyphs
    #     legends[legend_name + String(idx)] = [g.ref()]
    #   plot_model.add_renderers([legend_renderer.ref()])

    return plot_model


  make_glyph_test = (test_name, data_source, defaults, glyphspecs, xrange, yrange, {dims, tools, axes, legend, legend_name, plot_title, reference_point}) ->
    dims ?= [400, 400]
    tools ?= true
    axes ?= true
    legend ?= true
    legend_name ?= "glyph"
    plot_title ?= ""

    return () ->
      expect(0)
      opts = {dims: dims, tools: tools, axes:axes, legend: legend, legend_name: legend_name, plot_title: plot_title, reference_point: reference_point}
      plot_model = make_glyph_plot(data_source, defaults, glyphspecs, xrange, yrange, opts)
      div = $('<div class="plotdiv"></div>')
      $('body').append(div)
      myrender  =  ->
        view = new plot_model.default_view(model: plot_model)
        div.append(view.$el)
        console.log('Test ' + test_name)
      _.defer(myrender)


  zip = () ->
    lengthArray = (arr.length for arr in arguments)
    length = Math.min(lengthArray...)
    for i in [0...length]
      arr[i] for arr in arguments

  r = new Random(123456789)

  x = (r.randf()*100 for i in _.range(4000))
  y = (r.randf()*100 for i in _.range(4000))
  radii = (r.randf()+0.3 for i in _.range(4000))
  colors = ("rgb(#{ Math.floor(50+2*val[0]) }, #{ Math.floor(30+2*val[1]) }, 150)" for val in zip(x, y))
  source = ColumnDataSource.Collection.create(
    data:
      x: x
      y: y
      radius: radii
      fill: colors
  )

  xdr = Range1d.Collection.create({start: 0, end: 100})
  ydr = Range1d.Collection.create({start: 0, end: 100})

  scatter = {
    x: 'x'
    y: 'y'
    radius: 'radius'
    radius_units: 'data'
    fill_color: 'fill'
    fill_alpha: 0.6
    type: 'circle',
    line_color: null
  }

  title = "Scatter Example"
  test(
    'scatter',
    make_glyph_test(title, source, {}, [scatter], xdr, ydr, {dims: [600, 600], plot_title:title, legend: false})
  )

