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
