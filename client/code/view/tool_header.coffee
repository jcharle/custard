window.ToolHeaderView = class ToolHeaderView extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tool_header', =>
      @$el.find('h2 a').text @model.get 'name'
      @$el.find('h1').append '<i class="icon-chevron-left"></i>'
      topAndTailDropdowns()
      # Morally: Find all tools that want to add menu items and
      # install a menu item for each one.  Right now: just add
      # the CSV download tool.
      $li = $('<li><a href="#">Download CSV</a></li>')
      $('a', $li).on 'click', (e) =>
        e.preventDefault()
        @model.exec './download'
      @$el.find('nav .export li:eq(0)').after($li)
