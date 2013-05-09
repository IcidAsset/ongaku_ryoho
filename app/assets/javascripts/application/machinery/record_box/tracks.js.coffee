class OngakuRyoho.Classes.Machinery.RecordBox.Tracks

  constructor: () ->
    @drag_icon = document.createElement("img")
    @drag_icon.src = "/assets/music-icon.svg"



  #
  #  Show current track
  #
  show_current_track: () ->
    $current_track = @group.view.$el.find(".track.playing")

    # scroll to current track
    if $current_track.length
      new_scroll_top = (@group.view.el.scrollTop +
        ($current_track.offset().top - @group.view.$el.offset().top))
      @group.view.el.scrollTop = new_scroll_top



  #
  #  Add playing class to track
  #
  add_playing_class_to_track: (track) ->
    return unless track

    # set elements
    $track = @group.view.$el.find(".track[rel=\"#{track.id}\"]")

    # set classes
    $track.parent().children(".track.playing").removeClass("playing")
    $track.addClass("playing")



  #
  #  Fetching and fetched events
  #
  fetched: () =>
    OngakuRyoho.Engines.Queue.reset_computed_next()
    @parent_group.Footer.machine.check_page_navigation()

    if @group.collection.length > 0 and @group.view.mode isnt "queue"
      this.add_playing_class_to_track(OngakuRyoho.People.SoundGuy.get_current_track())
      this.show_current_track()



  #
  #  Activate track
  #
  activate_track: (el) =>
    $t = $(el)

    # check
    return if $t.hasClass("unavailable")

    # set
    track = @group.collection.get($t.attr("rel"))

    # insert track
    OngakuRyoho.Engines.Queue.clear_computed_next()
    OngakuRyoho.Engines.Queue.add_current_to_history()
    OngakuRyoho.Engines.Queue.set_current({ id: track.get("id"), user: true })
    OngakuRyoho.People.SoundGuy.insert_track(track)



  #
  #  Track rating star click event
  #
  track_rating_star_click: (e) =>
    $t = $(e.currentTarget)
    $track = $t.closest(".track")

    available = !$track.hasClass("unavailable")
    track_id = parseInt($track.attr("rel"))

    # if the track exists
    if available
      track = @group.collection.get(track_id)
      title = track.get("title")
      artist = track.get("artist")
      album = track.get("album")

      if $t.attr("data-favourite") is "true"
        $t.attr("data-favourite", "false")

        @parent_group.Favourites.collection
          .remove_matching_favourites(title, artist, album)

      else
        $t.attr("data-favourite", "true")

        new_favourite = @parent_group.Favourites.collection
          .create({
            title: title,
            artist: artist,
            album: album,
            track_id: track_id
          }, { wait: true })

        track.set("favourite_id", true)

    # if the track doesn't exist
    # e.g. unavailable track
    else
      favourites = @parent_group.Favourites.collection.where({ track_id: track_id })
      _.each favourites, (f) -> f.destroy()

    # remove dom element if needed
    # and also add 'nothing here' message if the collection is empty
    if @group.collection.favourites is on
      $track.remove() unless track_id

      if @group.collection.length is 0
        @group.view.add_nothing_here_message()

    # prevent default
    e.preventDefault()
    e.stopPropagation()
    return false



  #
  #  Drag & Drop
  #
  track_dragstart: (e) =>
    if e.dataTransfer
      e.dataTransfer.effectAllowed = "move"
      e.dataTransfer.dropEffect = "move"
      e.dataTransfer.setData("text/plain", $(e.currentTarget).attr("rel"))
      e.dataTransfer.setDragImage(@drag_icon, 17, 17)



  track_dragend: (e) ->
    e.dataTransfer.clearData() if e.dataTransfer
