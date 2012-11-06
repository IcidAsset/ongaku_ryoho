class OngakuRyoho.Classes.Machinery.Playlist.Navigation

  #
  #  A bit of everything
  #
  theater_mode_button_click_handler: (e) ->
    state = if $(e.currentTarget).hasClass("on") then "off" else "on"

    # enable / disable
    Helpers.set_theater_mode(state)



  #
  #  Show favourites
  #
  show_favourites: (e) =>
    tracks_collection = @parent_group.Tracks.collection
    favourites = tracks_collection.favourites
    $t = $(e.currentTarget)

    # switch
    if favourites
      $t.removeClass("on")
      tracks_collection.favourites = off

    else
      $t.addClass("on")
      tracks_collection.favourites = on

    # fetch tracks
    tracks_collection.fetch()



  #
  #  Show queue
  #
  show_queue: (e) =>
    tracks_view = @parent_group.Tracks.view
    queue_mode = tracks_view.mode is "queue"
    $t = $(e.currentTarget)

    # switch
    if queue_mode
      $t.removeClass("on")
      tracks_view.mode = "default"

    else
      $t.addClass("on")
      tracks_view.mode = "queue"

    # event
    tracks_view.render()



  #
  #  Show source manager
  #
  show_source_manager: (e) =>
    OngakuRyoho.SourceManager.view.show()



  #
  #  Sort by
  #
  sort_by_change_handler: (e) =>
    value = e.currentTarget.options[e.currentTarget.selectedIndex].value

    # sort by
    this.sort_by(value) if value



  sort_by: (query) ->
    @parent_group.Tracks.collection.sort_by = query
    @parent_group.Tracks.collection.fetch()



  change_sort_direction: (e) =>
    tracks_collection = @parent_group.Tracks.collection
    sort_direction = tracks_collection.sort_direction
    $t = $(e.currentTarget)

    # switch
    if sort_direction == "asc"
      tracks_collection.sort_direction = "desc"
      $t.addClass("on")

    else
      tracks_collection.sort_direction = "asc"
      $t.removeClass("on")

    # reload tracks
    tracks_collection.fetch()



  #
  #  Search
  #
  search_input_change: (e) =>
    $t = $(e.currentTarget)
    value = $t.val()

    # search
    this.search(value)



  search: (query) ->
    tracks_collection = @parent_group.Tracks.collection
    tracks_collection.filter = query
    tracks_collection.page = 1

    # fetch tracks
    tracks_collection.fetch({ success: this.search_success })



  search_success: () =>
    current_track = OngakuRyoho.People.SoundGuy.get_current_track()

    # add playing class
    @parent_group.Tracks.machine.add_playing_class_to_track(current_track) if current_track
