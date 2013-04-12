class OngakuRyoho.Classes.Collections.Tracks extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Track
  url: "/data/tracks/"


  #
  #  Initialize
  #
  initialize: () ->
    @page = 1
    @per_page = 500
    @filter = ""
    @sort_by = "artist"
    @sort_direction = "asc"

    # special filters
    @favourites = off
    @playlist = off



  #
  #  Fetch
  #
  fetch: (options={}) ->
    success = options.success

    # new message
    message = new OngakuRyoho.Classes.Models.Message
      text: "Loading tracks",
      loading: true

    # add message
    OngakuRyoho.MessageCenter.collection.add(message)

    # trigger 'fetching' event
    this.trigger("fetching")

    # check options
    options.data ?= {}

    # pagination, filter, etc.
    _.extend options.data, {
      page: @page,
      per_page: @per_page,
      filter: @filter,
      sort_by: @sort_by,
      sort_direction: @sort_direction,
      favourites: @favourites,
      playlist: @playlist
    }

    # success
    options.success = (response) =>
      success(this, response) if success
      OngakuRyoho.MessageCenter.collection.remove(message)
      this.trigger("fetched")
      message = null

    # call super
    return Backbone.Collection.prototype.fetch.call(this, options)


  #
  #  Parse
  #
  parse: (response) ->
    @page = response.page
    @per_page = response.per_page
    @total = response.total
    return response.models


  #
  #  Page info
  #
  page_info: () ->
    info =
      total: @total
      page: @page
      per_page: @per_page
      pages: Math.ceil(@total / @per_page)
      prev: false
      next: false

    # max
    if @total is @pages * @per_page
      max = @total
    else
      max = Math.min(@total, @page * @per_page)

    # range
    info.range = [(@page - 1) * @per_page + 1, max]

    # previous and next
    if @page > 1
      info.prev = @page - 1

    if @page < info.pages
      info.next = @page + 1

    # return
    return info


  #
  #  Previous page
  #
  previous_page: () ->
    return no unless this.page_info().prev

    @page = @page - 1
    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()

    return this.fetch()


  #
  #  Next page
  #
  next_page: () ->
    return no unless this.page_info().next

    @page = @page + 1
    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()

    return this.fetch()



  #
  #  Get random track
  #
  get_random_track: (ids_array=[]) ->
    filtered_tracks = this.reject (t) ->
      return _.include(ids_array, t.get("id"))

    # shuffle & get first
    return _.shuffle(filtered_tracks)[0]
