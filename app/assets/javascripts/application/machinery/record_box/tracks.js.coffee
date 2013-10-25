class OngakuRyoho.Classes.Machinery.RecordBox.Tracks

  constructor: () ->
    @drag_icon = document.createElement("img")
    @drag_icon.src = "/assets/music-icon.svg"



  #
  #  Track dblclick/doubleTap handler
  #
  track_dblclick_handler: (e) =>
    this.activate_track($(e.target).closest(".track")[0])



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
  fetching: () =>
    @group.view.el.scrollTop = 0
    @group.view.el.classList.add("disable-scrolling")
    @group.view.add_loading_message()



  fetched: () =>
    OngakuRyoho.Engines.Queue.reset_computed_next()
    OngakuRyoho.RecordBox.Footer.machine.check_page_navigation()
    @group.view.el.classList.remove("disable-scrolling")

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
    track = @group.collection.get(el.getAttribute("rel"))

    # insert track
    OngakuRyoho.Engines.Queue.clear_computed_next()
    OngakuRyoho.Engines.Queue.add_current_to_history()
    OngakuRyoho.Engines.Queue.set_current({ id: track.get("id"), user: true })
    OngakuRyoho.People.SoundGuy.insert_track(track)



  #
  #  Track rating star click event
  #
  track_rating_star_click: (e) =>
    $track = $(e.currentTarget).closest(".track")

    # check
    if $track.attr("rel")
      track_id = parseInt($track.attr("rel"), 10)
      @group.collection.toggle_favourite(track_id)

    else
      favourite_id = parseInt($track.children(".favourite").attr("data-favourite-id"), 10)
      OngakuRyoho.RecordBox.Favourites.collection.get(favourite_id).destroy()

    # remove dom element if needed
    # and also add 'nothing here' message if the collection is empty
    if OngakuRyoho.RecordBox.Filter.model.get("favourites") is on
      $track.remove() unless track_id

      if @group.collection.length is 0
        @group.view.add_nothing_here_message()

    # prevent default
    e.preventDefault()
    e.stopPropagation()



  #
  #  Move elements in queue
  #
  move_elements_in_queue: (source_index, target_index) ->
    queue = OngakuRyoho.Engines.Queue

    # source
    source_origin_name = if source_index < queue.data.user_next.length
      "user"
    else
      "computed"

    # target
    target_origin_name = if target_index <= queue.data.user_next.length
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



  #
  #  Drag & Drop / Track
  #
  track_dragstart: (e) =>
    if e.dataTransfer
      e.dataTransfer.effectAllowed = "move"
      e.dataTransfer.dropEffect = "move"
      e.dataTransfer.setData("text/plain", $(e.currentTarget).attr("rel"))
      e.dataTransfer.setDragImage(@drag_icon, 17, 17)

      @group.view.dragged_track_element = e.currentTarget



  track_dragend: (e) ->
    e.dataTransfer.clearData() if e.dataTransfer



  track_dragenter: (e) =>
    setTimeout(() =>
      cond_a = (@group.view.mode is "queue")
      cond_b = (OngakuRyoho.RecordBox.Filter.model.is_in_playlist_mode())

      if cond_a or cond_b
        e.currentTarget.classList.add("drag-target")
    , 0)



  track_dragleave: (e) =>
    setTimeout(() =>
      e.currentTarget.classList.remove("drag-target")
    , 0)



  track_dragover: (e) =>
    e.preventDefault()
    e.dataTransfer.dropEffect = "move"



  track_drop: (e) =>
    if @group.view.mode is "queue"
      this.track_drop_queue(e)
    else if OngakuRyoho.RecordBox.Filter.model.is_in_playlist_mode()
      this.track_drop_playlist(e)



  track_drop_queue: (e) ->
    e.stopPropagation()
    e.preventDefault()

    # elements
    $source = $(@group.view.dragged_track_element)
    $target = $(e.currentTarget)
    $target.removeClass("drag-target")

    # check
    return if $source.length is 0

    # move
    source_index = @group.view.$el.find(".track").index($source)
    target_index = @group.view.$el.find(".track").index($target)

    this.move_elements_in_queue(source_index, target_index)



  track_drop_playlist: (e) ->
    e.stopPropagation()
    e.preventDefault()

    # elements
    source_el = @group.view.dragged_track_element
    target_el = e.currentTarget
    target_el.classList.remove("drag-target")

    # check
    return unless source_el

    # move
    source_el.parentNode.insertBefore(source_el, target_el)

    # get playlist
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(
      OngakuRyoho.RecordBox.Filter.model.get("playlist")
    )

    # move around
    twp = _.sortBy(playlist.get("tracks_with_position"), (pt) -> pt.position)
    map = _.map(twp, (pt) -> pt.id)

    source_pt_id = source_el.getAttribute("data-playlist-track-id")
    target_pt_id = target_el.getAttribute("data-playlist-track-id")

    source_index = map.indexOf(parseInt(source_pt_id, 10))
    target_index = map.indexOf(parseInt(target_pt_id, 10))
    target_index = target_index - 1 if source_index < target_index

    source_pt = twp.splice(source_index, 1)
    twp.splice(target_index, 0, source_pt[0])

    source_pt_id = map.splice(source_index, 1)
    map.splice(target_index, 0, source_pt_id[0])

    # save
    playlist.save({ tracks_with_position: twp }, { validate: false })

    # update positions in dom
    track_elements = OngakuRyoho.RecordBox.Tracks.view.el.querySelectorAll(".tracks .track")
    _.each(track_elements, (track_element) ->
      pt_id = parseInt(track_element.getAttribute("data-playlist-track-id"), 10)
      new_position = map.indexOf(pt_id) + 1
      track_element.querySelector(".position span").innerHTML = new_position
    )



  pointerdown_handler: (e) ->
    # $(document).on("pointermove", (e) ->
    #   console.log(e)
    # )

    # $(document).on("pointerup", (e) ->
    #   $(document).off("pointermove")
    # )



  #
  #  Drag & Drop / Group
  #
  group_dragenter: (e) =>
    setTimeout(() =>
      if @group.view.mode is "queue"
        @group.view.$el.find(".track").first().addClass("drag-target")
    , 0)



  group_dragleave: (e) =>
    @group.view.$el.find(".track").first().removeClass("drag-target")



  group_dragover: (e) ->
    e.preventDefault()
    e.dataTransfer.dropEffect = "move"



  group_drop: (e) =>
    unless @group.view.mode is "queue" then return

    # stop them bubbles
    e.stopPropagation()
    e.preventDefault()

    # elements
    $source = $(@group.view.dragged_track_element)

    # check
    return if $source.length is 0

    # move
    source_index = @group.view.$el.find(".track").index($source)
    target_index = 0

    this.move_elements_in_queue(source_index, target_index)

