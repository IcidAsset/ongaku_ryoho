class OngakuRyoho.Classes.Machinery.TrackList

  #
  #  Fetching and fetched events
  #
  fetched: () =>
    ℰ.PlaylistView.machine.check_page_navigation()

    if @view.collection.length is 0
      @view.$el.html("<div class=\"nothing-here\" />")

    else
      this.add_playing_class_to_track( ℰ.SoundGuy.get_current_track() )
      ℰ.PlaylistView.machine.show_current_track()



  #
  #  Resize
  #
  resize: (e) =>
    $list = @view.$el.closest(".list")

    new_height = (
      $(window).height() - 2 * 50 -
      $list.prev(".navigation").height() - 2 * 2 -
      $list.children("header").height() -
      $list.next("footer").height()
    )

    $tw = @view.$el

    $tw.height(new_height) if $tw



  #
  #  Add playing class to track
  #
  add_playing_class_to_track: (track) =>
    return unless track

    # set elements
    $track = @view.$el.find(".track[rel=\"#{track.cid}\"]")

    # set classes
    $track.parent().children(".track.playing").removeClass("playing")
    $track.addClass("playing")



  #
  #  Play track
  #
  play_track: (e) =>
    $t = $(e.currentTarget)

    # check
    # TODO: return if not soundManager.ok() or $t.hasClass("unavailable")
    return if $t.hasClass("unavailable")

    # set
    track = ℰ.Tracks.getByCid($t.attr("rel"))

    # insert track
    ℰ.SoundGuy.insert_track(track)

    # set elements
    $playpause_button_light = ℰ.ControllerView.$el.find(".controls a .button.play-pause .light")

    # turn the play button light on
    $playpause_button_light.addClass("on")



  #
  #  Track rating star click event
  #
  track_rating_star_click: (e) =>
    $t = $(e.currentTarget)
    $track = $t.closest(".track")
    track = @view.collection.getByCid($track.attr("rel"))

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



  create_new_favourite: (title, artist, album, track_id) =>
    ℰ.Favourites.create({
      title: title,
      artist: artist,
      album: album,
      track_id: track_id
    })



  remove_matching_favourites: (title, artist, album) =>
    favourites = ℰ.Favourites.where({
      title: title,
      artist: artist,
      album: album
    })

    # destroy each
    _.each favourites, (f) -> f.destroy()
