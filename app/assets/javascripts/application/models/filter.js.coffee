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
    this.on("change:sort_by", this.sort_by_change_handler)
    this.on("change:sort_direction", this.sort_by_change_handler)



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
    searches = if query.charAt(0).match(/^(\+|\-)$/g)
      this.get("searches").slice(0)
    else
      []

    # check
    if query.length is 0
      return no

    # update query depending on action
    if query.charAt(0) is "-"
      query = "!#{query.substr(1)}"
      query = this.clean_up_search_query(query, 1)
    else
      query = query.substr(1) if query.charAt(0) is "+"
      query = this.clean_up_search_query(query)

    # check again
    if query.length is 0
      return message = new OngakuRyoho.Classes.Models.Message({
        text: "Invalid search query",
        error: true
      })

    # set searches
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



  clean_up_search_query: (query, from_index) ->
    new_query = query
    new_query = new_query.substr(from_index) if from_index
    new_query = new_query.replace(/(\:|\*|\&|\||\'|\"|\+|\!)+/g, "")
    new_query = query.substr(0, from_index) + new_query if from_index
    new_query



  #
  #  Reset
  #
  search_action_reset: () ->
    this.set("page", 1, { silent: true })



  #
  #  Other
  #
  sort_by_change_handler: (e) ->
    OngakuRyoho.RecordBox.Navigation.machine.add_active_class_to_selected_sort_by_column()



  remove_last_filter_in_line: () ->
    attr = this.attributes

    if attr.searches.length > 0
      this.remove_search_query(_.last(attr.searches))
    else if attr.favourites
      this.disable_favourites()

    # else if attr.playlist
      # TODO
