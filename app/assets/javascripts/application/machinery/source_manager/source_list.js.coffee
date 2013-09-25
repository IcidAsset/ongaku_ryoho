class OngakuRyoho.Classes.Machinery.SourceManager.SourceList

  #
  #  Light
  #
  light_click_handler: (e) =>
    id = $(e.currentTarget).closest(".source").attr("rel")
    model = OngakuRyoho.SourceManager.collection.get(id)

    # check
    return unless model.get("processed")

    # save
    model.save(
      { activated: !model.get("activated") },
      { success: () -> OngakuRyoho.RecordBox.Tracks.collection.fetch() }
    )

    # render list
    @view.render("SourceList", "main")



  #
  #  Tooltip
  #
  setup_new_tooltip_instance: () ->
    machine = this

    @tooltip = new BareTooltip(@view.$el, {
      trigger_type: "click",
      tooltip_klass: "tooltip grey",
      animation_speed: 0,
      timeout_duration: 0,
      delegate_selector: ".source .menu > a",
      template: """
        <div class="{{CLASSES}}">
          <div class="arrow"></div>
          {{CONTENT}}
        </div>
      """
    })

    # extend
    @tooltip.show_tooltip = () ->
      this.state.$tooltip_element.on("click", "a[rel=\"remove\"]", machine.tooltip_remove_click_handler)
      this.state.$tooltip_element.on("click", "a[rel=\"edit\"]", machine.tooltip_edit_click_handler)
      this.state.$tooltip_element.on("click", "a[rel=\"bind-to-current-ip\"]", machine.tooltip_bind_to_current_ip_click_handler)

      BareTooltip.prototype.show_tooltip.apply(this)

    @tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("click")

      BareTooltip.prototype.hide_tooltip.apply(this, arguments)

    @tooltip.move_tooltip = (e) ->
      $t = this.state.$tooltip_element
      $trigger = $(e.currentTarget)

      $t.css({
        left: $trigger.offset().left + Math.round($trigger.width() / 2) - Math.round($t.width() / 2),
        top: $trigger.offset().top + $trigger.height() + 9
      })

    # setup
    @tooltip.setup()



  self_destruct_current_tooltip_instance: () ->
    @tooltip.self_destruct() if @tooltip
    @tooltip = null



  tooltip_remove_click_handler: (e) =>
    collection = OngakuRyoho.SourceManager.collection
    source_id = @tooltip.state.$current_trigger.closest(".source").attr("rel")
    source_id = parseInt(source_id, 10)

    if collection.is_fetching or collection.is_updating
      alert("Sources are currently being updated. Try again later.")
    else
      source = collection.get(source_id)
      source.destroy()



  tooltip_edit_click_handler: (e) =>
    collection = OngakuRyoho.SourceManager.collection
    source_id = @tooltip.state.$current_trigger.closest(".source").attr("rel")
    source_id = parseInt(source_id, 10)
    source = collection.get(source_id)

    if source
      OngakuRyoho.SourceManager.view.fill_in_and_show_edit_form(source)



  tooltip_bind_to_current_ip_click_handler: (e) =>
    collection = OngakuRyoho.SourceManager.collection
    source_id = @tooltip.state.$current_trigger.closest(".source").attr("rel")
    source_id = parseInt(source_id, 10)

    if collection.is_fetching or collection.is_updating
      alert("Sources are currently being updated. Try again later.")
    else
      OngakuRyoho.SourceManager.view.add_working_class_to_refresh_sources_button()
      callback = () -> OngakuRyoho.SourceManager.view.render("SourceList", "main")

      source = collection.get(source_id)
      source.save({ configuration: { boundary: OngakuRyohoPreloadedData.user_ip } }, success: callback)
