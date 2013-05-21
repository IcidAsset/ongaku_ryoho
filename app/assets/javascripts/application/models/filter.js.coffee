class OngakuRyoho.Classes.Models.Filter extends Backbone.Model

  defaults:
    playlist: off
    searches: []
    favourites: off
    page: 1
    per_page: 1000
    total: 0
    sort_by: "artist"
    sort_direction: "asc"


  initialize: () ->
    this.on("change", this.change_handler)


  change_handler: () ->
    return unless OngakuRyoho.People.ViewStateManager.state.ready
    OngakuRyoho.RecordBox.Tracks.collection.fetch()
    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()


  #
  #  Favourites
  #
  toggle_favourites: () ->
    this.search_action_reset()
    this.set("favourites", !this.get("favourites"))


  disable_favourites: () ->
    this.search_action_reset()
    this.set("favourites", off)


  #
  #  Search
  #
  add_search_query: (query) ->
    searches = this.get("searches").slice(0)
    searches.push(query)
    this.search_action_reset()
    this.set("searches", searches)


  remove_search_query: (query) ->
    searches = this.get("searches").slice(0)
    indexof_query = _.indexOf(searches, query)

    if indexof_query isnt -1
      searches.splice(indexof_query, 1)
      this.search_action_reset()
      this.set("searches", searches)


  #
  #  Reset
  #
  search_action_reset: () ->
    this.set("page", 1, { silent: true })
