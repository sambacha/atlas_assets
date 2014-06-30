# Two ways to createa a Select dropdown
#
# Start with a Backbone Collection and a specified label
#
# select_view = new classes.SelectView({
#   collection:some_collection,
#   label: "name"
# })
#
# Start with an array
#
# select_view = new classes.SelectView({
#   values: ["rune","steve","zach"]
# })

class classes.SelectView extends Backbone.View

  defaults: {label: 'label'}
  className: "select-dropdown"

  initialize: (options) ->
    @rendered = false

    @label = if options.label then options.label else "label"
    @helper = options.helper if options.helper?

    # The select view needs a collection.
    if !@collection
      @collection = @collection_from_values(options.values)
    else if @collection.length > 0
      t = @
      @collection.each (model,@label) -> t.set_model_label(model)

    @template = JST["templates/select"]
    @listenTo(@collection, 'add', @add_model)
    @listenTo(@collection, 'remove', @render)
    @listenTo(@, 'rendered', @bind_select)

  collection_from_values: (values) ->
    @collection = new Backbone.Collection(_.map(values, (v) ->
      return {"label": v}
    ))
    @collection.comparator = "label"
    @collection.sort()

  add_model: (m) ->
    @set_model_label(m)
    select_el = @$el.find('select').first()
    select_el.append("<option>#{m.get('label')}</option>")

    sort_by_name = (a, b) ->
      a.innerHTML.toLowerCase().localeCompare(b.innerHTML.toLowerCase())

    options = select_el.children().get().sort(sort_by_name)
    for opt in options
      select_el.append(opt)

  set_model_label: (model) =>
    model.set('label',model.get(@label))

  bind_select: ->
    t = @
    @rendered = true
    @select = new Select({
      el: @$el.find('select')[0]
      className: 'select-theme-atlas'
    })

    @select.on('change', (v) ->
      selected_model = t.collection.find((model) -> model.get(t.label) is v.value)
      t.trigger('change', selected_model)
    )

  get_value: -> @select.value
  get_model: ->
    value = @select.value
    @collection.find (model) => model.get('label') is value

  set: (value) -> @select.change(value)

  render: =>
    @collection.comparator = "label"
    @$el.html(@template({models:@collection.sort().models, helper:@helper}))
    @trigger('rendered') if !@rendered
    @
