class OngakuRyoho.Classes.Views.Playlist extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .navigation .change-sort-direction" : "change_sort_direction"
    "click .navigation .theater-mode" : @machine.theater_mode_button_click_handler
    "click .navigation .show-favourites" : "show_favourites"
    "click .navigation .show-source-manager" : "show_source_manager"

    "change .navigation .sort-by select" : "sort_by_change_handler"
    "change .navigation .search input" : "search_input_change"

    "click footer .page-nav .previous:not(.disabled)" : @machine.previous_page_button_click_handler
    "click footer .page-nav .next:not(.disabled)" : @machine.next_page_button_click_handler



  #
  #  Initialize
  #
  initialize: () =>
    super()

    # tracklist view
    @track_list_view = new OngakuRyoho.Classes.Views.TrackList({
      el: this.$(".tracks-wrapper")
    })

    # search
    this.$search = this.$(".navigation .search input")

    # get content
    ℰ.Sources.fetch({ success: () ->
      ℰ.Tracks.fetch({ success: ℰ.SourceManagerView.check_sources })
    })



  #
  #  Show favourites
  #
  show_favourites: (e) =>
    $t = $(e.currentTarget)

    # switch
    if Tracks.favourites
      $t.removeClass("on")
      ℰ.Tracks.favourites = off

    else
      $t.addClass("on")
      ℰ.Tracks.favourites = on


    # fetch tracks
    ℰ.Tracks.fetch()



  #
  #  Show source manager
  #
  show_source_manager: () =>
    ℰ.SourceManagerView.show()



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
    ℰ.Tracks.fetch()



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
    @track_list_view.collection.filter = query
    @track_list_view.collection.page = 1

    # fetch tracks
    ℰ.Tracks.fetch({ success: this.search_success })



  search_success: () =>
    current_track = ℰ.SoundGuy.get_current_track()

    # add playing class
    @track_list_view.add_playing_class_to_track(current_track) if current_track



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



  #
  #  Set footer contents
  #
  set_footer_contents: (html) =>
    this.$el.find("footer .intestines").html(html)
