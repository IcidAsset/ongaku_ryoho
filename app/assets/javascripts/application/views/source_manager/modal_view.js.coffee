class OngakuRyoho.Classes.Views.SourceManager.Modal extends Backbone.View

  events: ->
    "click .toolbar [rel='close-modal']" : "hide"
    "click .toolbar [rel='add-source']" : @machine.toolbar_add_source
    "click .toolbar [rel='refresh-sources']:not(.working)" : @machine.toolbar_refresh_sources
    "click .toolbar [rel='go-back']" : @machine.toolbar_go_back
    "click [data-window]" : @machine.data_window_click_handler
    "submit form" : @machine.form_submit_handler



  initialize: () ->
    @machine = new OngakuRyoho.Classes.Machinery.SourceManager.Modal
    @machine.view = this

    # collection events
    this.listenTo(
      OngakuRyoho.SourceManager.collection, "remove",
      () -> OngakuRyoho.RecordBox.Tracks.collection.fetch()
    )

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
    @current_child_view.after_append() if @current_child_view.after_append



  #
  #  Details
  #
  add_working_class_to_refresh_sources_button: () ->
    this.$el.find(".toolbar [rel='refresh-sources']").addClass("working")


  remove_working_class_from_refresh_sources_button: () ->
    this.$el.find(".toolbar [rel='refresh-sources']").removeClass("working")
