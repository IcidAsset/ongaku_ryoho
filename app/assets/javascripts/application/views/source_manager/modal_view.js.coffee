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
  #  Windows
  #
  show_window: (window_class) ->
    $wndw = this.$el
      .children(".window")
      .removeClass("shown")
      .filter(".#{window_class}")

    $wndw.find(".error").remove()
    $wndw.addClass("shown")

    @current_window = window_class



  #
  #  Rendering
  #
  render: (item="SourceList", window_check) ->
    return if window_check and @current_window isnt window_check
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


  add_error_message_to_shown_window: (error_msg) ->
    error_msg ?= "Please fill in all fields"
    error_html = "<div class=\"error\">#{error_msg}</div>"

    $div = this.$el.find(".window.shown section .scrollable > .clear")
    $div.find(".error").remove()
    $div.append(error_html)



  #
  #  Forms
  #
  fill_in_and_show_edit_form: (source) ->
    type = source.get("type")
    source_attr = source.toJSON()

    $form_new = this.$el.find(".window form[data-type='#{type}'][data-action='CREATE']")
    $form_edit = this.$el.find(".window form[data-type='#{type}'][data-action='UPDATE']")

    $form_edit.attr("data-source-id", source.get("id"))
    $form_edit.html($form_new.html())
    $form_edit.find("[name]:not([type='submit'])").each(() ->
      name = this.getAttribute("name")
      match = name.match(/(\w+)\[(\w+)\]/)
      value = if match then source_attr[match[1]][match[2]] else source_attr[name]

      if this.getAttribute("type") is "checkbox"
        if value is "1"
          this.setAttribute("checked", "checked")
        else
          this.removeAttribute("checked")
      else
        this.setAttribute("value", value || "")
    )

    window_klass = $form_edit.closest(".window").attr("class").split(" ")[1]
    this.show_window(window_klass)
