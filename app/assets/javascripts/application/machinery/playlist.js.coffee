PlaylistMachinery =

  #
  #  A bit of everything
  #
  show_current_track: () ->
    $current_track = @view.track_list_view.$(".track.playing")

    # scroll to current track
    if $current_track.length
      new_scroll_top = (@view.track_list_view.el.scrollTop +
      ($current_track.offset().top - @view.track_list_view.$el.offset().top))

      @view.track_list_view.el.scrollTop = new_scroll_top



  theater_mode_button_click_handler: (e) ->
    state = if $(e.currentTarget).hasClass("on") then "off" else "on"

    # enable / disable
    Helpers.set_theater_mode(state)



  #
  #  Page navigation
  #
  previous_page_button_click_handler: (e) ->
    ℰ.PlaylistView.track_list_view.collection.previous_page()



  next_page_button_click_handler: (e) ->
    ℰ.PlaylistView.track_list_view.collection.next_page()



#### MC
mc = PlaylistMachinery



#### Publicize
OngakuRyoho.Machinery.Playlist = _.pick(PlaylistMachinery,
  "show_current_track", "theater_mode_button_click_handler",
  "previous_page_button_click_handler", "next_page_button_click_handler"
)
