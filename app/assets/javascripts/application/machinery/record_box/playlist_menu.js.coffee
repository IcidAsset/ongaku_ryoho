class OngakuRyoho.Classes.Machinery.RecordBox.PlaylistMenu

  constructor: () ->
    @timeout_ids = []



  #
  #  Close button
  #
  setup_close_button: () ->
    @group.view.$el.find(".icon.close")
      .on("click", this.close_button_click_handler)



  close_button_click_handler: (e) ->
    e.stopPropagation()
    e.preventDefault()

    OngakuRyoho.RecordBox.Tracks.collection.playlist = off
    OngakuRyoho.RecordBox.Tracks.collection.fetch()

    $select_wrap = $(e.currentTarget).parent()
    $select_wrap.removeClass("activated")
    $select_wrap.children("span").html(
      $select_wrap.children("span").attr("data-default") + ""
    )



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

      this.state.$tooltip_element.on("dragenter", "a[rel]", self.item_dragenter)
      this.state.$tooltip_element.on("dragleave", "a[rel]", self.item_dragleave)
      this.state.$tooltip_element.on("dragover", "a[rel]", self.item_dragover)
      this.state.$tooltip_element.on("drop", "a[rel]", self.item_drop)

      self.group.view.$el.addClass("on")

      BareTooltip.prototype.show_tooltip.apply(this)

    @tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("click")
      this.state.$tooltip_element.off("dragenter")
      this.state.$tooltip_element.off("dragleave")
      this.state.$tooltip_element.off("drop")

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
  #  Tooltip / event handlers
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



  #
  #  Drag & drop
  #
  item_dragenter: (e) ->
    e.currentTarget.classList.add("drag-target")


  item_dragleave: (e) ->
    e.currentTarget.classList.remove("drag-target")


  item_dragover: (e) ->
    e.preventDefault()
    e.dataTransfer.dropEffect = "copyMove"


  item_drop: (e) ->
    e.currentTarget.classList.remove("drag-target")

    # get track
    track_id = parseInt(e.dataTransfer.getData("text/plain"), 10)
    track = OngakuRyoho.RecordBox.Tracks.collection.get(track_id)

    # get playlist and update it
    playlist_cid = e.currentTarget.getAttribute("rel")
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(playlist_cid)
    playlist_track_ids = playlist.get("track_ids")
    playlist_track_ids.push(track_id)
    OngakuRyoho.RecordBox.Playlists.collection.sync("update", playlist)

    # add message
    message = new OngakuRyoho.Classes.Models.Message
      text: "<span class=\"icon\" data-icon=\"&#9776;\"></span>
            #{track.get('artist')} - #{track.get('title')}"

    OngakuRyoho.MessageCenter.collection.add(message) if track

    # remove message
    setTimeout(() ->
      OngakuRyoho.MessageCenter.collection.remove(message)
      message = null
    , 1500) if track
