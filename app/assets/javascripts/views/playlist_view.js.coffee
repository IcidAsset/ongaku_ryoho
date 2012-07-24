class OngakuRyoho.Views.Playlist extends Backbone.View

  #
  #  Events
  #
  events:
    "click .navigation .theater-mode" : "theater_mode_button_click_handler"
    "click .navigation .show-source-manager" : "show_source_manager"
    "click .navigation .change-sort-direction" : "change_sort_direction"

    "change .navigation .sort-by select" : "sort_by_change_handler"
    "change .navigation .search input" : "search_input_change"

    "click footer .page-nav .previous:not(.disabled)" : "previous_page_button_click_handler"
    "click footer .page-nav .next:not(.disabled)" : "next_page_button_click_handler"



  #
  #  Initialize
  #
  initialize: () =>

    # tracklist view
    @track_list_view = new OngakuRyoho.Views.TrackList({
      el: this.$el.find(".tracks-wrapper")
    })

    # search
    this.$search = this.$el.find(".navigation .search input")

    # get content
    Sources.fetch({ success: () -> Tracks.fetch({ success: SourceManagerView.check_sources }) })



  #
  #  Source manager
  #
  show_source_manager: () =>
    SourceManagerView.show()



  #
  #  Sort by
  #
  sort_by_change_handler: (e) =>
    value = e.currentTarget.options[e.currentTarget.selectedIndex].value

    # sort by
    this.sort_by(value) if value



  sort_by: (query) =>
    @track_list_view.collection.sort_by = query

    # fetch tracks
    Tracks.fetch()



  change_sort_direction: (e) =>
    current_direction = @track_list_view.collection.sort_direction
    $t = $(e.currentTarget)

    # switch
    if current_direction == "asc"
      new_direction = "desc"
      $t.addClass("on")

    else
      new_direction = "asc"
      $t.removeClass("on")

    # change
    @track_list_view.collection.sort_direction = new_direction

    # reload tracks
    Tracks.fetch()



  #
  #  Search
  #
  search_input_change: (e) =>
    $t = $(e.currentTarget)
    value = $t.val()

    # search
    this.search(value)



  search: (query) =>
    @track_list_view.collection.filter = query
    @track_list_view.collection.page = 1

    # fetch tracks
    Tracks.fetch({ success: this.search_success })



  search_success: () =>
    current_track = SoundGuy.get_current_track()

    # add playing class
    @track_list_view.add_playing_class_to_track(current_track) if current_track



  #
  #  A bit of everything
  #
  show_current_track: () =>
    $current_track = @track_list_view.$el.find(".track.playing")

    # scroll to current track
    if $current_track.length
      new_scroll_top = ( @track_list_view.el.scrollTop +
      ($current_track.offset().top - @track_list_view.$el.offset().top))

      @track_list_view.el.scrollTop = new_scroll_top



  theater_mode_button_click_handler: (e) =>
    state = if $(e.currentTarget).hasClass("on") then "off" else "on"

    # enable / disable
    helpers.set_theater_mode(state)



  #
  #  Page navigation
  #
  check_page_navigation: () =>
    page_info = @track_list_view.collection.page_info()
    $previous = this.$el.find("footer .page-nav .previous")
    $next = this.$el.find("footer .page-nav .next")

    # check
    unless page_info.prev then $previous.addClass("disabled")
    else $previous.removeClass("disabled")

    unless page_info.next then $next.addClass("disabled")
    else $next.removeClass("disabled")



  previous_page_button_click_handler: (e) =>
    @track_list_view.collection.previous_page()



  next_page_button_click_handler: (e) =>
    @track_list_view.collection.next_page()



  #
  #  Set footer contents
  #
  set_footer_contents: (html) =>
    this.$el.find("footer .intestines").html(html)
