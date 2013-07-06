class OngakuRyoho.Classes.Machinery.SourceManager.SourceList

  #
  #  Light
  #
  light_click_handler: (e) =>
    id = $(e.currentTarget).closest(".source").attr("rel")
    model = OngakuRyoho.SourceManager.collection.get(id)
    model.save(
      { activated: !model.get("activated") },
      { success: () -> OngakuRyoho.RecordBox.Tracks.collection.fetch() }
    )

    # render list
    @group.view.render()



  #
  #  Tooltip
  #
  setup_new_tooltip_instance: () ->
    $elements = @group.view.$el.find(".source .menu a")

    @tooltip = new BareTooltip($elements, {
      trigger_type: "click",
      tooltip_klass: "tooltip grey",
      animation_speed: 0,
      timeout_duration: 0,
      template: '<div class="{{CLASSES}}">' +
        '<div class="arrow"></div>' +
        '{{CONTENT}}' +
      '</div>'
    })

    # extend
    @tooltip.show_tooltip = () ->
      # this.state.$tooltip_element.on("click", "a[rel=\"set-theater-mode\"]", _this.theater_mode_toggle)

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



  tooltip_remove_click_handler: (e) ->
    #
