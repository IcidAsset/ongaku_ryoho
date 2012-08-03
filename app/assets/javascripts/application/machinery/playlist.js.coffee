class OngakuRyoho.Classes.Machinery.Playlist

  #
  #  A bit of everything
  #
  show_current_track: () =>
    track_list_view = @view.track_list_view
    $current_track = track_list_view.$(".track.playing")

    # scroll to current track
    if $current_track.length
      new_scroll_top = (track_list_view.el.scrollTop +
      ($current_track.offset().top - track_list_view.$el.offset().top))

      track_list_view.el.scrollTop = new_scroll_top



  theater_mode_button_click_handler: (e) ->
    state = if $(e.currentTarget).hasClass("on") then "off" else "on"

    # enable / disable
    Helpers.set_theater_mode(state)



  #
  #  Show favourites
  #
  show_favourites: (e) =>
    $t = $(e.currentTarget)

    # switch
    if ℰ.Tracks.favourites
      $t.removeClass("on")
      ℰ.Tracks.favourites = off

    else
      $t.addClass("on")
      ℰ.Tracks.favourites = on


    # fetch tracks
    ℰ.Tracks.fetch()



  #
  #  Sort by
  #
  sort_by_change_handler: (e) =>
    value = e.currentTarget.options[e.currentTarget.selectedIndex].value

    # sort by
    this.sort_by(value) if value



  sort_by: (query) =>
    ℰ.Tracks.sort_by = query

    # fetch tracks
    ℰ.Tracks.fetch()



  change_sort_direction: (e) =>
    current_direction = ℰ.Tracks.sort_direction
    $t = $(e.currentTarget)

    # switch
    if current_direction == "asc"
      new_direction = "desc"
      $t.addClass("on")

    else
      new_direction = "asc"
      $t.removeClass("on")

    # change
    ℰ.Tracks.sort_direction = new_direction

    # reload tracks
    ℰ.Tracks.fetch()



  #
  #  Search
  #
  search_input_change: (e) =>
    $t = $(e.currentTarget)
    value = $t.val()

    # search
    this.search(value)



  search: (query) =>
    @view.track_list_view.collection.filter = query
    @view.track_list_view.collection.page = 1

    # fetch tracks
    ℰ.Tracks.fetch({ success: this.search_success })



  search_success: () =>
    current_track = ℰ.SoundGuy.get_current_track()

    # add playing class
    @view.track_list_view.add_playing_class_to_track(current_track) if current_track



  #
  #  Page navigation
  #
  previous_page_button_click_handler: (e) =>
    @view.track_list_view.collection.previous_page()



  next_page_button_click_handler: (e) =>
    @view.track_list_view.collection.next_page()



  check_page_navigation: () =>
    page_info = @view.track_list_view.collection.page_info()
    $previous = @view.$("footer .page-nav .previous")
    $next = @view.$("footer .page-nav .next")

    # check
    unless page_info.prev then $previous.addClass("disabled")
    else $previous.removeClass("disabled")

    unless page_info.next then $next.addClass("disabled")
    else $next.removeClass("disabled")
