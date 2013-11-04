
  Collections = Bokeh.Collections

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
        glyph = Collections('Glyph').create({
        #glyph = GlyphFactory.Collection.create({
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
        glyph = Collections('Glyph').create({
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
      title: plot_title)

    plot_model.set(defaults)
    plot_model.add_renderers(g.ref() for g in glyphs)
    if axes
      xaxis1 = Collections('LinearAxis').create(
        dimension: 0
        axis_label: 'x'
        plot: plot_model.ref()
      )
      yaxis1 = Collections('LinearAxis').create(
        dimension: 1
        axis_label: 'y'
        plot: plot_model.ref()
      )
      xaxis2 = Collections('LinearAxis').create(
        dimension: 0
        location: 'max'
        plot: plot_model.ref()
      )
      yaxis2 = Collections('LinearAxis').create(
        dimension: 1
        location: 'max'
        plot: plot_model.ref()
      )
      xgrid = Collections('Grid').create(
        dimension: 0
        plot: plot_model.ref()
      )
      ygrid = Collections('Grid').create(
        dimension: 1
        plot: plot_model.ref()
      )
      plot_model.add_renderers(
        [xgrid.ref(), ygrid.ref(), xaxis1.ref(), yaxis1.ref(), xaxis2.ref(), yaxis2.ref()]
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
      selecttool = Collections('BoxSelectTool').create(
        renderers : (x.ref() for x in glyphs)
      )
      boxselectionoverlay = Collections('BoxSelection').create(
        tool : selecttool.ref()
      )
      resizetool = Collections('ResizeTool').create()
      pstool = Collections('PreviewSaveTool').create()
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




  zip = () ->
    lengthArray = (arr.length for arr in arguments)
    length = Math.min(lengthArray...)
    for i in [0...length]
      arr[i] for arr in arguments

  r = new Bokeh.Random(123456789)

  x = (r.randf()*100 for i in _.range(4000))
  y = (r.randf()*100 for i in _.range(4000))
  radii = (r.randf()+0.3 for i in _.range(4000))
  colors = ("rgb(#{ Math.floor(50+2*val[0]) }, #{ Math.floor(30+2*val[1]) }, 150)" for val in zip(x, y))
  source = Collections('ColumnDataSource').create(
    data:
      x: x
      y: y
      radius: radii
      fill: colors
  )

  xdr = Collections('Range1d').create({start: 0, end: 100})
  ydr = Collections('Range1d').create({start: 0, end: 100})

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

  opts = {dims: [600, 600], tools: true, axes: true, legend: false, plot_title: "Scatter Demo"}
  plot_model = make_glyph_plot(source, {}, [scatter], xdr, ydr, opts)
  div = $('<div class="plotdiv"></div>')
  $('body').append(div)
  myrender  =  ->
    view = new plot_model.default_view(model: plot_model)
    div.append(view.$el)
    console.log('Scatter Demo')
  _.defer(myrender)
