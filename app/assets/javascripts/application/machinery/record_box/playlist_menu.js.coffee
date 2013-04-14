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
      this.state.$tooltip_element.on("click", ".playlist-add input[type=\"submit\"]", self.add_playlist)
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
  #  Add playlist
  #
  add_playlist: (e) ->
    $t = $(e.currentTarget)
    $add_playlist = $t.parent()

    name = $add_playlist.find("input[type='text']").val()
    playlist = new OngakuRyoho.Classes.Models.Playlist({ name: name })

    if playlist.isValid()
      OngakuRyoho.RecordBox.Playlists.collection.create(playlist)
    else
      playlist = null
      alert("Please enter a valid name for your playlist")
