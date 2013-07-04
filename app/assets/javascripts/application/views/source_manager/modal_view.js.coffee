class OngakuRyoho.Classes.Views.SourceManager.Modal extends Backbone.View

  events:
    "click .toolbar [rel='close-modal']" : "hide"
    "click .toolbar [rel='add-source']" : "toolbar_add_source"
    "click .toolbar [rel='refresh-sources']:not(.working)" : "toolbar_refresh_sources"
    "click .toolbar [rel='go-back']" : "toolbar_go_back"
    "click [data-window]" : "data_window_click_handler"
    "submit form" : "form_submit_handler"



  initialize: () ->
    super

    # this element
    Helpers.set_view_element(this, ".mod-source-manager")



  #
  #  Show & Hide
  #
  show: () ->
    this.show_window("main")
    this.render()
    this.$el.show(0)



  hide: () ->
    this.$el.hide(0)



  #
  #  Show window
  #
  show_window: (window_class) ->
    this.$el
      .children(".window")
      .removeClass("shown")
      .filter("[class*=\"#{window_class}\"]")
      .addClass("shown")



  #
  #  Rendering
  #
  render: (item="SourceList") ->
    @current_child_view.remove() if @current_child_view
    @current_child_view = new OngakuRyoho.Classes.Views.SourceManager[item]
    @current_child_view.render().$el.appendTo(this.$el.find(".window.shown section"))



  #
  #  Toolbar event handlers
  #
  toolbar_add_source: (e) =>
    this.show_window("add-source-menu")



  toolbar_refresh_sources: (e) ->
    collection = OngakuRyoho.SourceManager.collection

    # check
    return if collection.is_fetching or collection.is_updating

    # add css class
    e.currentTarget.classList.add("working")

    # fetch and then remove css class
    Helpers.promise_fetch(OngakuRyoho.SourceManager.collection)
      .then -> OngakuRyoho.SourceManager.collection.update_tracks_on_all()
      .then -> Helpers.promise_fetch(OngakuRyoho.RecordBox.Tracks.collection)
      .then -> e.currentTarget.classList.remove("working")



  toolbar_go_back: (e) =>
    this.show_window(e.currentTarget.getAttribute("data-to"))



  #
  #  Other event handlers
  #
  data_window_click_handler: (e) =>
    this.show_window(e.currentTarget.getAttribute("data-window"))


  form_submit_handler: (e) ->
    $form = $(e.currentTarget)

    # prevent default
    e.preventDefault()

    # serialize
    attrs = { type: $form.attr("data-type") }
    attrs_array = $form.serializeArray()

    _.each(attrs_array, (v, k) ->
      if (index = v.name.indexOf("[")) isnt -1
        parent_key = v.name.substring(0, index)
        key = v.name.substring(index + 1, v.name.lastIndexOf("]"))
        attrs[parent_key] ?= {}
        attrs[parent_key][key] = v.value
      else
        attrs[v.name] = v.value
    )

    # action
    if $form.attr("data-action") is "CREATE"
      OngakuRyoho.SourceManager.collection.create(attrs, { wait: true })
