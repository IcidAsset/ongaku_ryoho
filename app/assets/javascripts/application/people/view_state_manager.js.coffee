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
      queue_status: this.get_queue_status(),
      filter: OngakuRyoho.RecordBox.Tracks.collection.filter,
      page: OngakuRyoho.RecordBox.Tracks.collection.page
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
      this.set_queue_status(state.queue_status)
      OngakuRyoho.RecordBox.Tracks.collection.filter = state.filter
      OngakuRyoho.RecordBox.Tracks.collection.page = state.page

    # state
    @state.ready = true

    # load data
    self = this
    this.load_favourites()
      .then -> self.load_playlists()
      .then -> self.load_sources()
      .then -> self.load_tracks()
      # .then -> self.process_and_check_sources()



  #
  #  Application data helpers
  #
  load_tracks: -> Helpers.promise_fetch(OngakuRyoho.RecordBox.Tracks.collection)
  load_favourites: -> Helpers.promise_fetch(OngakuRyoho.RecordBox.Favourites.collection)
  load_playlists: -> Helpers.promise_fetch(OngakuRyoho.RecordBox.Playlists.collection)
  load_sources: -> Helpers.promise_fetch(OngakuRyoho.SourceManager.collection)
  process_and_check_sources: -> OngakuRyoho.SourceManager.collection.process_and_check_sources()



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
    RB.Tracks.view.mode = "queue"
    RB.Tracks.view.render()
    RB.Footer.machine.disable_navigation_entirely()


  hide_queue: () ->
    RB = OngakuRyoho.RecordBox
    RB.Navigation.view.$el.find(".toggle-queue").removeClass("on")
    RB.Tracks.view.mode = "default"
    RB.Tracks.view.render()
    RB.Tracks.machine.show_current_track()
    RB.Footer.machine.check_page_navigation()

    if RB.Tracks.collection.length > 0
      current_track = OngakuRyoho.People.SoundGuy.get_current_track()
      RB.Tracks.machine.add_playing_class_to_track(current_track)
      RB.Tracks.machine.show_current_track()
