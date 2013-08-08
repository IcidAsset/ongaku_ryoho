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
    @group.view.$el.scrollTop(0)
    @group.view.$el.addClass("disable-scrolling")
    @group.view.add_loading_message()


  fetched: () =>
    OngakuRyoho.Engines.Queue.reset_computed_next()
    OngakuRyoho.RecordBox.Footer.machine.check_page_navigation()
    @group.view.$el.removeClass("disable-scrolling")

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
    $track = $(e.currentTarget).closest(".track")
    track_id = parseInt($track.attr("rel"), 10)

    # pass to collection
    @group.collection.toggle_favourite(track_id)

    # remove dom element if needed
    # and also add 'nothing here' message if the collection is empty
    if @group.collection.favourites is on
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
      $(e.currentTarget).addClass("drag-target") if @group.view.mode is "queue"
    , 0)



  track_dragleave: (e) =>
    setTimeout(() =>
      $(e.currentTarget).removeClass("drag-target")
    , 0)



  track_dragover: (e) =>
    e.preventDefault()
    e.dataTransfer.dropEffect = "move"



  track_drop: (e) =>
    unless @group.view.mode is "queue" then return

    # stop them bubbles
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

