class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list row'

  initialize: ->
    app.datasets().on 'sync', @addDatasets, @

  events:
    'click .new-dataset-tile': ->
      $('#subnav .new-dataset').trigger('click') # :TODO: this is nasty and hacky

  render: ->
    @$el.append $('<a class="new-dataset-tile swcol" title="Add a new dataset">Create a<br/>new dataset</a>').hide().fadeIn(150)
    @addDatasets() if app.datasets().length
    @

  addDatasets: ->
    app.datasets().visible().each @addDataset

  addDataset: (dataset, i) =>
    view = new Cu.View.DatasetTile model: dataset
    @$el.append $(view.render().el).hide().delay(i*75 + 100).fadeIn(150)
