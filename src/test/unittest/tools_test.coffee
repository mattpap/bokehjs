test('test_interactive', ()->
  expect(0)
  data_source1 = Bokeh.Collections['ObjectArrayDataSource'].create({
    data : [{x : 1, y : -2},
      {x : 2, y : -3},
      {x : 3, y : -4},
      {x : 4, y : -5},
      {x : 5, y : -6}]
  }, {'local' : true})
  container = Bokeh.Collections['InteractiveContext'].create(
    {}, {'local' : true});
  plot1 = Bokeh.scatter_plot(container, data_source1, 'x', 'y', 'x', 'circle')
  container.set({'children' : [plot1.ref()]})
  plot1.set('offset', [100, 100])
  scatterrenderer = plot1.resolve_ref(plot1.get('renderers')[0])
  pantool = Bokeh.Collections['PanTool'].create(
    {'xmappers' : [scatterrenderer.get('xmapper')],
    'ymappers' : [scatterrenderer.get('ymapper')]}
    , {'local':true})
  plot1.set('tools', [pantool.ref()])
  window.plot1 = plot1
  window.myrender = () ->
    view = new container.default_view({'model' : container});
    view.render()
    plot1.set({'width' : 300})
    plot1.set({'height' : 300})
    window.view = view
  _.defer(window.myrender)
)