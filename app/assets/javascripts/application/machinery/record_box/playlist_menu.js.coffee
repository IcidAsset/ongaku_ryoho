class OngakuRyoho.Classes.Machinery.RecordBox.PlaylistMenu

  add_active_class_to_selected_playlist: () ->
    filter = OngakuRyoho.RecordBox.Filter.model
    selector = ".playlists .playlist"

    # get playlist model
    playlist_model = if filter.get("playlist_isspecial")
      OngakuRyoho.RecordBox.Playlists.collection.findWhere({
        name: filter.get("playlist_name")
      })
    else
      OngakuRyoho.RecordBox.Playlists.collection.get(
        filter.get("playlist")
      )

    # playlist model cid
    cid = if playlist_model
      playlist_model.cid
    else
      false

    # set classes
    @group.view.$el.find(selector).removeClass("selected")
    @group.view.$el.find(selector).filter("[data-playlist-cid='#{cid}']").addClass("selected") if cid



  #
  #  Playlist left-click
  #
  playlist_click_handler: (e) =>
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(
      e.currentTarget.getAttribute("data-playlist-cid")
    )

    # enable playlist
    OngakuRyoho.RecordBox.Filter.model.enable_playlist(playlist)

    # hide menu
    if OngakuRyohoPreloadedData.user.settings.hide_playlist_menu is "1"
      @group.view.hide()



  #
  #  Add-playlist form
  #
  add_playlist_submit_handler: (e) =>
    $input = @group.view.$el.find(".add-playlist input[type=\"text\"]")

    # do not actually submit form
    e.preventDefault()

    # new model
    playlist = new OngakuRyoho.Classes.Models.Playlist({
      name: $input.val()
    })

    # if the new model is valid,
    # save it and add success class to $input
    if playlist.isValid()
      playlist.save({}, {
        success: () ->
          OngakuRyoho.RecordBox.Playlists.collection.add(playlist)
      })

      $input.removeClass("error")
      $input.val("")
      $input.addClass("success")
      _.delay((() -> $input.removeClass("success")), 1000)

    # if it isn't valid,
    # add error class to $input
    else
      $input.addClass("error")



  #
  #  Tooltip
  #
  setup_tooltip: () ->
    machine = this

    @tooltip = new BareTooltip(@group.view.$el, {
      trigger_type: "contextmenu",
      tooltip_klass: "tooltip subtle-green",
      delegate_selector: ".playlist",
      animation_speed: 0,
      timeout_duration: 0,
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

      BareTooltip.prototype.show_tooltip.apply(this)

    @tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("click")

      BareTooltip.prototype.hide_tooltip.apply(this, arguments)

    @tooltip.move_tooltip = (e) ->
      $t = this.state.$tooltip_element
      $trigger = $(e.currentTarget)

      $t.css({
        left: $trigger.offset().left + Math.round($trigger.width() / 2) - Math.round($t.width() / 2),
        top: $trigger.offset().top + $trigger.height() / 2 + 14
      })

    # setup
    @tooltip.setup()



  tooltip_remove_click_handler: (e) =>
    playlist_cid = @tooltip.state.$current_trigger.attr("data-playlist-cid")
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(playlist_cid)

    # filter
    if OngakuRyoho.RecordBox.Filter.model.get("playlist") is playlist.get("id")
      OngakuRyoho.RecordBox.Filter.model.set("playlist", off)

    # destroy playlist
    OngakuRyoho.RecordBox.Playlists.collection.remove(playlist)
    playlist.destroy()



  #
  #  Drag & drop
  #
  playlist_dragenter: (e) ->
    e.currentTarget.classList.add("drag-target")



  playlist_dragleave: (e) ->
    e.currentTarget.classList.remove("drag-target")



  playlist_dragover: (e) ->
    e.preventDefault()
    e.dataTransfer.dropEffect = "move"



  playlist_drop: (e) ->
    id = parseInt(e.dataTransfer.getData("text/plain"), 10)

    # get track
    track = OngakuRyoho.RecordBox.Tracks.collection.get(id)

    # remove class
    e.currentTarget.classList.remove("drag-target")

    # get playlist
    playlist_cid = e.currentTarget.getAttribute("data-playlist-cid")
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(playlist_cid)

    if playlist.get("special")
      return alert("You can't add tracks to a special playlist!")
    else
      tracks_with_position = playlist.get("tracks_with_position")
      position = _.keys(tracks_with_position).length + 1
      new_track_ids = tracks_with_position.slice(0)
      new_track_ids.push({ track_id: parseInt(id, 10), position: position })

      playlist.save({
        track_ids: new_track_ids
      })

    # add message
    message = new OngakuRyoho.Classes.Models.Message
      text: "<span class=\"icon\" data-icon=\"&#57349;\"></span>
            #{track.get('artist')} - #{track.get('title')}"

    OngakuRyoho.MessageCenter.collection.add(message)

    # remove message
    _.delay(() ->
      OngakuRyoho.MessageCenter.collection.remove(message)
      message = null
    , 1500)
