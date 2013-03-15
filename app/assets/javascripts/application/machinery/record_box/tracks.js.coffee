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

    track_id = unless $track.hasClass("unavailable")
      parseInt($track.attr("rel"))
    else
      false

    # if the track exists
    if track_id
      track = @group.collection.get(track_id)
      title = track.get("title")
      artist = track.get("artist")
      album = track.get("album")

      if $t.data("favourite") is true or $t.data("favourite") is "true"
        $t.attr("data-favourite", false)
        $t.data("favourite", false)

        this.remove_matching_favourites(title, artist, album)

      else
        $t.attr("data-favourite", true)
        $t.data("favourite", true)

        this.create_new_favourite(title, artist, album, track_id)

    # if the track doesn't exist
    # e.g. unavailable track
    else
      @parent_group.Favourites.collection.get(
        $track.data("favourite-id")
      ).destroy()

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



  #
  #  Drag & Drop
  #
  track_dragstart: (e) =>
    if e.dataTransfer
      e.dataTransfer.effectAllowed = "move"
      e.dataTransfer.dropEffect = "move"
      e.dataTransfer.setData("text/plain", $(e.currentTarget).attr("rel"))
      e.dataTransfer.setDragImage(@drag_icon, 17, 17)

      @group.view.dragged_track_element = e.currentTarget



  track_dragend: (e) ->
    e.dataTransfer.clearData()



  track_dragenter: (e) =>
    if @group.view.mode is "queue" then $(e.currentTarget).addClass("drag-target")



  track_dragleave: (e) =>
    if @group.view.mode is "queue" then $(e.currentTarget).removeClass("drag-target")



  track_dragover: (e) =>
    e.preventDefault()
    e.dataTransfer.dropEffect = "move"



  track_drop: (e) =>
    unless @group.view.mode is "queue" then return

    # stop them bubbles
    e.stopPropagation()
    e.preventDefault()

    # set
    queue = OngakuRyoho.Engines.Queue

    # source
    $s = $(@group.view.dragged_track_element)
    return if $s.length is 0

    source_index = @group.view.$el.find(".track").index($s)
    source_origin_name = if source_index < queue.data.user_next.length
      "user"
    else
      "computed"

    # target
    $t = $(e.currentTarget)
    $t.removeClass("drag-target")

    target_index = @group.view.$el.find(".track").index($t)
    target_origin_name = if target_index < queue.data.user_next.length
      "user"
    else
      "computed"

    # fix numbers
    if source_origin_name is "computed"
      source_index = source_index - queue.data.user_next.length

    if target_origin_name is "computed"
      target_index = target_index - queue.data.user_next.length

    if source_origin_name is target_origin_name
      if source_index < target_index
        target_index = target_index - 1

    # get source queue item
    source_queue_item = queue.data["#{source_origin_name}_next"].splice(source_index, 1)[0]

    # alter queue item
    if source_origin_name isnt target_origin_name
      source_queue_item.user = !source_queue_item.user

    # shift queue
    queue.data["#{target_origin_name}_next"].splice(target_index, 0, source_queue_item)
    queue.set_next()
