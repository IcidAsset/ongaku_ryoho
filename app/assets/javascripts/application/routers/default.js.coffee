class OngakuRyoho.Classes.Routers.Default extends Backbone.Router

  routes:
    "queue" : "queue"
    "favourites(/:page)" : "favourites"
    "source_manager" : "source_manager"
    ":query(/:page)" : "search_index"



  #
  #  Initialize
  #
  initialize: () ->
    Backbone.history.start()



  #
  #  Route callbacks
  #
  search: (query, page) ->
    App.RecordBox.Tracks.collection.filter = query
    App.RecordBox.Tracks.collection.page = parseInt(page || 1, 10)
    this.load_tracks()


  search_index: (query, page) ->
    page = unless isNaN(query) then query else page
    this.load_favourites().then -> this.search(query || "", page)


  queue: () ->
    this.load_favourites()
      .then -> this.load_tracks()
      .then -> OngakuRyoho.RecordBox.Navigation.machine.show_queue()


  favourites: (page) ->
    console.log("favourites - page:", page)


  source_manager: () ->
    console.log("source manager")



  #
  #  Application data
  #
  load_tracks: -> Helpers.promise_fetch(App.RecordBox.Tracks.collection)
  load_favourites: -> Helpers.promise_fetch(App.RecordBox.Favourites.collection)
  load_sources: -> Helpers.promise_fetch(App.SourceManager.collection)
  process_and_check_sources: -> App.SourceManager.collection.process_and_check_sources()

  first_time_deferrer: (bypass=false, method) ->
    if OngakuRyoho
