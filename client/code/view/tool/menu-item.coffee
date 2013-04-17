# This should be passed a dataset/view model, not a tool archetype model
class Cu.View.ToolMenuItem extends Backbone.View
  tagName: 'li'
  events:
    'click .hide': 'hideTool'
    'click .git-ssh': ->
      Cu.Helpers.showOrAddSSH @model.get('box'), @model.get('displayName'), 'dataset'

  hideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @$el.slideUp()
    @model.save {state: 'deleted'}

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    if @model instanceof Cu.Model.Dataset
      href = "/dataset/#{@model.get 'box'}/settings"
    else
      href = "/dataset/#{@model.get('plugsInTo').get('box')}/view/#{@model.get 'box'}"
    html = JST['tool-menu-item']
      manifest: @model.get('tool').get('manifest')
      href: href
      id: "instance-#{@model.get 'box'}"
      toolName: @model.get('tool').get('name')
    $(html).appendTo @$el
    @

# This should be passed a tool archetype model, not a dataset/view model
class Cu.View.ArchetypeMenuItem extends Backbone.View
  tagName: 'li'

  initialize: ->
    @options.archetype.on 'change', @render, this

  events:
    'click a': 'clicked'

  render: ->
    if app.tools().length
      @a = $( JST['tool-menu-item'] manifest: @options.archetype.get('manifest') ).appendTo @$el
    @

  clicked: (e) ->
    e.stopPropagation()
    @install(e) unless @active

  # Copied from client/code/view/tool/tile.coffee
  install: (e) ->
    e.preventDefault()
    @active = true
    console.log "loading..."

    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: @options.dataset.id

    dataset.fetch
      success: (dataset, resp, options) =>
        dataset.installPlugin @options.archetype.get('name'), (err, view) =>
          console.warn 'Error', err if err?
          window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true
      error: (model, xhr, options) ->
        @active = false
        console.warn xhr
