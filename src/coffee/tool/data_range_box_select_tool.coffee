
define [
  "underscore",
  "backbone",
  "./box_selecttool",
] (_, Backbone, BoxSelectTool) ->

  # data range box selection tool differs from our other select tool
  # in that it just stores the selected ranges on itself
  # also it points to a plot, rather than the renderers
  class DataRangeBoxSelectToolView extends BoxSelectTool.View
    bind_bokeh_events: () ->
      #HACK!!!!!
      tool.ToolView::bind_bokeh_events.call(this)

    _select_data: () ->
      [xstart, ystart] = @plot_view.mapper.map_from_target(
        @xrange[0], @yrange[0])
      [xend, yend] = @plot_view.mapper.map_from_target(
        @xrange[1], @yrange[1])
      @mset('xselect', [xstart, xend])
      @mset('yselect', [ystart, yend])
      @model.save()

  class DataRangeBoxSelectTool extends BoxSelectTool.Model
    type: "DataRangeBoxSelectTool"
    default_view: DataRangeBoxSelectToolView

  DataRangeBoxSelectTool::defaults = _.clone(DataRangeBoxSelectTool::defaults)

  class DataRangeBoxSelectTools extends Backbone.Collection
    model : DataRangeBoxSelectTool

  return {
    "Model": DataRangeBoxSelectTool,
    "Collection": new DataRangeBoxSelectTools(),
    "View": DataRangeBoxSelectToolView,
  }
