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
      timeout_duration: 0,
      template: '<div class="{{CLASSES}}">' +
        '<div class="arrow"></div>' +
        '{{CONTENT}}' +
      '</div>';
    })

    # extend
    @tooltip.show_tooltip = () ->
      this.state.$tooltip_element.on("click", ".group.ignore-click-hide", (e) -> e.stopPropagation())
      this.state.$tooltip_element.on("click", ".playlist-add input[type=\"submit\"]", self.add_button_click_handler)
      this.state.$tooltip_element.on("click", ".group[rel] a", self.playlist_click_handler)
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



  #
  #  Event handlers
  #
  add_button_click_handler: (e) ->
    $t = $(e.currentTarget)
    $add_playlist = $t.parent()

    name = $add_playlist.find("input[type='text']").val()
    playlist = new OngakuRyoho.Classes.Models.Playlist({ name: name })

    show_error = (message) ->
      playlist = null
      alert(message)

    if playlist.isValid()
      playlist.save(null, {
        success: -> OngakuRyoho.RecordBox.Playlists.collection.add(playlist),
        error: -> show_error("Could not create playlist, please try again")
      })
    else
      show_error(playlist.validationError)



  playlist_click_handler: (e) =>
    rel = e.currentTarget.getAttribute("rel")
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(rel)
    return unless playlist

    OngakuRyoho.RecordBox.Tracks.collection.playlist = if playlist.get("special")
      "#{playlist.get("name")}/"
    else
      playlist.get("id")

    OngakuRyoho.RecordBox.Tracks.collection.fetch()

    @group.view.$el.children("span:first-child").html(playlist.get("name"))
    @group.view.$el.addClass("activated")
