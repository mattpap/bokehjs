Collections = require('../base').Collections

wave_demo = (div_id) ->

  xs = ( (x/50) for x in _.range(630) )
  ys = (Math.sin(x) for x in xs)
  colors = ("rgb(#{ Math.floor(155+100*val) }, #{ Math.floor(100+50*val) }, #{ Math.floor(150-50*val) })" for val in ys)
  source = Collections('ColumnDataSource').create(
    data:
      x: xs
      y: ys
      fill: colors
  )


  xdr = Collections('DataRange1d').create(
    sources: [{ref: source.ref(), columns: ['x']}]
  )

  ydr = Collections('DataRange1d').create(
    sources: [{ref: source.ref(), columns: ['y']}]
  )

  bars = {
    x: 'x'
    y: 'y'
    width: 0.01
    height: 0.4
    type: 'rect',
    fill: 'fill'
    line_color: null
    angle: 0.1
  }

  this.make_plot(div_id, source, {}, [bars], xdr, ydr, {dims: [600, 600], plot_title: "", legend: false})

this.wave_demo = wave_demo

