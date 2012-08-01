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
  #  Page navigation
  #
  previous_page_button_click_handler: (e) =>
    @view.track_list_view.collection.previous_page()



  next_page_button_click_handler: (e) =>
    @view.track_list_view.collection.next_page()
