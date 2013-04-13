class OngakuRyoho.Classes.Machinery.RecordBox.PlaylistMenu

  constructor: () ->
    @timeout_ids = []



  #
  #  Tooltip
  #
  setup_tooltip: () ->
    self = this

    @tooltip = new BareTooltip(@group.view.$el, {
      trigger_type: "click",
      tooltip_klass: "mod-playlist-menu tooltip",
      animation_speed: 0,
      timeout_duration: 15000,
      template: '<div class="{{CLASSES}}">' +
        '<div class="arrow"></div>' +
        '{{CONTENT}}' +
      '</div>';
    })

    # extend
    @tooltip.show_tooltip = () ->
      # this.state.$tooltip_element.on("click", "a[rel=\"set-theater-mode\"]", self.theater_mode_toggle)
      # this.state.$tooltip_element.on("click", "a[rel=\"source-manager\"]", self.source_manager_toggle)
      self.group.view.$el.addClass("on")

      BareTooltip.prototype.show_tooltip.apply(this)

    @tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("click")
      self.group.view.$el.removeClass("on")

      BareTooltip.prototype.hide_tooltip.apply(this, arguments)

    @tooltip.move_tooltip = (e) ->
      $t = this.state.$tooltip_element
      $trigger = $(e.currentTarget)

      $t.css({
        left: $trigger.offset().left + Math.round($trigger.width() / 2) - Math.round($t.width() / 2),
        top: $trigger.offset().top + $trigger.height() + 10
      })

    # setup
    @tooltip.setup()

