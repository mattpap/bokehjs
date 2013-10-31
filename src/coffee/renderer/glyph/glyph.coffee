
define (_, HasParent, PlotWidget) ->

  _ = require("underscore")
  HasParent = require("common/has_parent")
  PlotWidget = require("common/plot_widget")
  a

  class GlyphView extends PlotWidget

    initialize: (options) ->
      super(options)
      @need_set_data = true

    set_data: (request_render=true) ->
      source = @mget_obj('data_source')
      #FIXME: should use some mechanism like isinstance
      if source.type == 'ObjectArrayDataSource'
        data = source.get('data')
      else if source.type == 'ColumnDataSource'
        data = source.datapoints()
      else if source.type == 'PandasPlotSource'
        data = source.datapoints()
      else
        console.log('Unknown data source type: ' + source.type)

      @_set_data(data)
      if request_render
        @request_render()

    render: (have_new_mapper_state=true) ->
      if @need_set_data
        @set_data(false)
        @need_set_data = false
      @_render(@plot_view, have_new_mapper_state)

    select: () ->
      'pass'

    xrange: () ->
      return @plot_view.x_range

    yrange: () ->
      return @plot_view.y_range

    bind_bokeh_events: () ->
      @listenTo(@model, 'change', @request_render)
      @listenTo(@mget_obj('data_source'), 'change', @set_data)

    distance: (data, pt, span, position) ->
      pt_units = @glyph_props[pt].units
      span_units = @glyph_props[span].units

      if      pt == 'x' then mapper = @plot_view.xmapper
      else if pt == 'y' then mapper = @plot_view.ymapper

      span = @glyph_props.v_select(span, data)
      if span_units == 'screen'
        return span

      if position == 'center'
        halfspan = (d / 2 for d in span)
        ptc = @glyph_props.v_select(pt, data)
        if pt_units == 'screen'
          ptc = mapper.v_map_from_target(ptc)
        pt0 = (ptc[i] - halfspan[i] for i in [0..ptc.length-1])
        pt1 = (ptc[i] + halfspan[i] for i in [0..ptc.length-1])

      else
        pt0 = @glyph_props.v_select(pt, data)
        if pt_units == 'screen'
          pt0 = mapper.v_map_from_target(pt0)
        pt1 = (pt0[i] + span[i] for i in [0..pt0.length-1])

      spt0 = mapper.v_map_to_target(pt0)
      spt1 = mapper.v_map_to_target(pt1)

      return (spt1[i] - spt0[i] for i in [0..spt0.length-1])

    get_reference_point: () ->
      reference_point = @mget('reference_point')
      if _.isNumber(reference_point)
        return @data[reference_point]
      else
        return reference_point

    draw_legend: (ctx, x1, x2, y1, y2) ->

  class Glyph extends HasParent

  Glyph::defaults = _.clone(Glyph::defaults)
  _.extend(Glyph::defaults,
    data_source: null
  )

  Glyph::display_defaults = _.clone(Glyph::display_defaults)
  _.extend(Glyph::display_defaults, {

    level: 'glyph'
    radius_units: 'screen'
    length_units: 'screen'
    angle_units: 'deg'
    start_angle_units: 'deg'
    end_angle_units: 'deg'

  })

  class Glyphs extends Backbone.Collection
    model: (attrs, options) ->

      annular_wedge     = require("./annular_wedge")
      annulus           = require("./annulus")
      arc               = require("./arc")
      asterisk          = require("./asterisk")
      bezier            = require("./bezier")
      circle            = require("./circle")
      circle_x          = require("./circle_x")
      circle_cross      = require("./circle_cross")
      diamond           = require("./diamond")
      diamond_cross     = require("./diamond_cross")
      image             = require("./image")
      image_rgba        = require("./image_rgba")
      image_uri         = require("./image_uri")
      inverted_triangle = require("./inverted_triangle")
      line              = require("./line")
      multi_line        = require("./multi_line")
      oval              = require("./oval")
      patch             = require("./patch")
      patches           = require("./patches")
      cross             = require("./cross")
      quad              = require("./quad")
      quadratic         = require("./quadratic")
      ray               = require("./ray")
      rect              = require("./rect")
      square            = require("./square")
      square_x          = require("./square_x")
      square_cross      = require("./square_cross")
      segment           = require("./segment")
      text              = require("./text")
      triangle          = require("./triangle")
      wedge             = require("./wedge")
      x                 = require("./x")

      glyphs = {
        "annular_wedge"     : annular_wedge.AnnularWedge,
        "annulus"           : annulus.Annulus,
        "arc"               : arc.Arc,
        "asterisk"          : asterisk.Asterisk,
        "bezier"            : bezier.Bezier,
        "circle"            : circle.Circle,
        "circle_x"          : circle_x.CircleX,
        "circle_cross"      : circle_cross.CircleCross,
        "diamond"           : diamond.Diamond,
        "diamond_cross"     : diamond_cross.DiamondCross,
        "image"             : image.Image,
        "image_rgba"        : image_rgba.ImageRGBA,
        "image_uri"         : image_uri.ImageURI,
        "inverted_triangle" : inverted_triangle.InvertedTriangle,
        "line"              : line.Line,
        "multi_line"        : multi_line.MultiLine,
        "oval"              : oval.Oval,
        "patch"             : patch.Patch,
        "patches"           : patches.Patches,
        "cross"             : cross.Cross,
        "quad"              : quad.Quad,
        "quadratic"         : quadratic.Quadratic,
        "ray"               : ray.Ray,
        "square"            : square.Square,
        "square_x"          : square_x.SquareX,
        "square_cross"      : square_cross.SquareCross,
        "rect"              : rect.Rect,
        "segment"           : segment.Segment,
        "text"              : text.Text,
        "triangle"          : triangle.Triangle,
        "wedge"             : wedge.Wedge,
        "x"                 : x.X,
      }


      if not attrs.glyphspec?.type?
        console.log "missing glyph type"
        return

      type = attrs.glyphspec.type

      if not (type of glyphs)
        console.log "unknown glyph type '" + type + "'"
        return

      model = glyphs[type]
      return new model(attrs, options)

  return {
    "Model": Glyph,
    "Collection": new Glyphs(),
    "View": GlyphView
  }
