class OngakuRyoho.Classes.Machinery.RecordBox.UserMenu

  #
  #  Tooltip
  #
  setup_tooltip: () ->
    _this = this

    @tooltip = new BareTooltip(@group.view.$el, {
      trigger_type: "click",
      tooltip_klass: "mod-user-menu tooltip",
      animation_speed: 0,
      timeout_duration: 0,
      template: '<div class="{{CLASSES}}">' +
        '<div class="arrow"></div>' +
        '{{CONTENT}}' +
      '</div>'
    })

    # extend
    @tooltip.show_tooltip = () ->
      this.state.$tooltip_element.on("click", "a[rel=\"set-theater-mode\"]", _this.theater_mode_toggle)
      this.state.$tooltip_element.on("click", "a[rel=\"source-manager\"]", _this.source_manager_toggle)
      this.state.$tooltip_element.on("click", "a[href]", _this.a_href_click_handler)
      _this.group.view.$el.addClass("on")

      BareTooltip.prototype.show_tooltip.apply(this)

    @tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("click")
      _this.group.view.$el.removeClass("on")

      BareTooltip.prototype.hide_tooltip.apply(this, arguments)

    @tooltip.move_tooltip = (e) ->
      $t = this.state.$tooltip_element
      $trigger = $(e.currentTarget)

      $t.css({
        left: $trigger.offset().left + Math.round($trigger.width() / 2) - Math.round($t.width() / 2) - 41,
        top: $trigger.offset().top + $trigger.height() + 9
      })

    # setup
    @tooltip.setup()


  a_href_click_handler: (e) =>
    e.preventDefault()
    window.location = e.currentTarget.getAttribute("href")



  #
  #  Theather mode
  #
  set_theater_mode_visibility: (state) ->
    animation_duration = 950

    # set elements
    $switch = @group.view.$el.find(".tooltip-data [rel=\"set-theater-mode\"]")
    $color_overlay = $(".mod-color-overlay")

    # go
    if state is "off"
      $switch.removeClass("on")
      $color_overlay.animate({ opacity: 0 }, { duration: animation_duration })

    else
      $switch.addClass("on")
      $color_overlay.animate({ opacity: 1 }, { duration: animation_duration })

    # save state in local storage
    window.localStorage.setItem("theater_mode_state", state)



  theater_mode_toggle: (e) =>
    $t = $(e.currentTarget)

    if $t.hasClass("on")
      this.set_theater_mode_visibility("off")
    else
      this.set_theater_mode_visibility("on")

    @tooltip.hide_and_remove_current_tooltip()
    e.stopPropagation()



  check_theater_mode: () ->
    theater_mode_state = window.localStorage.getItem("theater_mode_state")
    theater_mode_state ?= "off"

    # set
    this.set_theater_mode_visibility(theater_mode_state)



  #
  #  Source manager
  #
  source_manager_toggle: (e) =>
    OngakuRyoho.SourceManager.view.show()
