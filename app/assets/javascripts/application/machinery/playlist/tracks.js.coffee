class OngakuRyoho.Classes.Machinery.Playlist.Tracks

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
  #  Fetching and fetched events
  #
  fetched: () =>
    OngakuRyoho.Engines.Queue.reset_all()
    @parent_group.Footer.machine.check_page_navigation()

    if @group.collection.length > 0
      this.add_playing_class_to_track(OngakuRyoho.People.SoundGuy.get_current_track())
      this.show_current_track()



  #
  #  Resize
  #
  resize: (e) =>
    $list = @group.view.$el.closest(".list")

    new_height = (
      $(window).height() - 2 * 50 -
      $list.prev(".navigation").height() - 2 * 2 -
      $list.children("header").height() -
      $list.next("footer").height()
    )

    $tw = @group.view.$el
    $tw.height(new_height) if $tw



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
  #  Track dblclick handler
  #
  track_dblclick: (e) =>
    $t = $(e.currentTarget)

    # check
    return if $t.hasClass("unavailable") || $t.hasClass("queue-item")

    # set
    track = @group.collection.getById($t.attr("rel"))

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
    track = @group.collection.getById($track.attr("rel"))

    title = track.get("title")
    artist = track.get("artist")
    album = track.get("album")
    track_id = track.get("id")

    # check
    if $t.data("favourite") is true or $t.data("favourite") is "true"
      $t.attr("data-favourite", false)
      $t.data("favourite", false)

      this.remove_matching_favourites(title, artist, album)

    else
      $t.attr("data-favourite", true)
      $t.data("favourite", true)

      this.create_new_favourite(title, artist, album, track_id)

    # prevent default
    e.preventDefault()
    e.stopPropagation()
    return false



  create_new_favourite: (title, artist, album, track_id) ->
    @parent_group.Favourites.collection.create({
      title: title,
      artist: artist,
      album: album,
      track_id: track_id
    })



  remove_matching_favourites: (title, artist, album) ->
    favourites = @parent_group.Favourites.collection.where({
      title: title,
      artist: artist,
      album: album
    })

    # destroy each
    _.each favourites, (f) -> f.destroy()
