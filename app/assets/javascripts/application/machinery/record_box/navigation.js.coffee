class OngakuRyoho.Classes.Machinery.RecordBox.Navigation

  #
  #  Queue
  #
  toggle_queue: (e) =>
    queue_mode = @parent_group.Tracks.view.mode is "queue"
    $t = $(e.currentTarget)

    # toggle
    if queue_mode
      this.hide_queue()
    else
      this.show_queue()



  show_queue: () ->
    @group.view.$el.find(".toggle-queue").addClass("on")
    @parent_group.Tracks.view.mode = "queue"
    @parent_group.Tracks.view.render()
    @parent_group.Footer.machine.disable_navigation_entirely()



  hide_queue: () ->
    @group.view.$el.find(".toggle-queue").removeClass("on")
    @parent_group.Tracks.view.mode = "default"
    @parent_group.Tracks.view.render()
    @parent_group.Tracks.machine.show_current_track()
    @parent_group.Footer.machine.check_page_navigation()

    if @parent_group.Tracks.collection.length > 0
      @parent_group.Tracks.machine.add_playing_class_to_track(
        OngakuRyoho.People.SoundGuy.get_current_track()
      )

      @parent_group.Tracks.machine.show_current_track()



  #
  #  Favourites
  #
  toggle_favourites: (e) =>
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
  #  User menu
  #
  toggle_user_menu: (e) ->
    if $(e.currentTarget).hasClass("on")
      OngakuRyoho.UserMenu.view.hide()
    else
      OngakuRyoho.UserMenu.view.show()



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
