class OngakuRyoho.Classes.People.ViewStateManager

  constructor: () ->
    @state = { ready: false }



  #
  #  Go to work
  #
  go_to_work: () ->
    this.apply_state_from_local_storage()



  #
  #  Local storage
  #
  save_state_in_local_storage: () ->
    state = {
      filter_attributes: OngakuRyoho.RecordBox.Filter.model.attributes
      queue_status: this.get_queue_status()
    }

    # store
    window.localStorage.setItem(
      "view_state",
      JSON.stringify(state)
    )


  apply_state_from_local_storage: () ->
    state = window.localStorage.getItem("view_state")

    # apply
    if state
      state = JSON.parse(state)
      OngakuRyoho.RecordBox.Filter.model.set(state.filter_attributes)
      this.set_queue_status(state.queue_status)

    # just to make sure
    OngakuRyoho.RecordBox.Filter.model.sort_by_change_handler()

    # state
    @state.ready = true

    # load data
    self = this
    this.load_favourites()
      .then -> self.load_sources()
      .then -> self.load_playlists()
      .then -> self.load_tracks()
      .then -> if location.hostname isnt "localhost" then self.update_sources()



  #
  #  Application data helpers
  #
  load_tracks: -> Helpers.promise_fetch(OngakuRyoho.RecordBox.Tracks.collection)
  load_favourites: -> Helpers.promise_fetch(OngakuRyoho.RecordBox.Favourites.collection)
  load_playlists: -> Helpers.promise_fetch(OngakuRyoho.RecordBox.Playlists.collection)
  load_sources: -> Helpers.promise_fetch(OngakuRyoho.SourceManager.collection)
  update_sources: -> OngakuRyoho.SourceManager.collection.update_tracks_on_all()



  #
  #  Queue
  #
  get_queue_status: () ->
    return OngakuRyoho.RecordBox.Tracks.view.mode is "queue"


  set_queue_status: (status) ->
    if status is on then this.show_queue()
    else if @state.ready then this.hide_queue()

    if @state.ready then this.save_state_in_local_storage()


  show_queue: () ->
    RB = OngakuRyoho.RecordBox
    RB.Navigation.view.$el.find(".toggle-queue").addClass("on")
    RB.Navigation.view.$track_list_header.addClass("queue-mode")
    RB.Tracks.view.mode = "queue"
    RB.Tracks.view.render()
    RB.Footer.machine.disable_navigation_entirely()


  hide_queue: () ->
    RB = OngakuRyoho.RecordBox
    RB.Navigation.view.$el.find(".toggle-queue").removeClass("on")
    RB.Navigation.view.$track_list_header.removeClass("queue-mode")
    RB.Tracks.view.mode = "default"
    RB.Tracks.view.render()
    RB.Footer.machine.check_page_navigation()

    if RB.Tracks.collection.length > 0
      current_track = OngakuRyoho.People.SoundGuy.get_current_track()
      RB.Tracks.machine.add_playing_class_to_track(current_track)
      RB.Tracks.machine.show_current_track()
