class OngakuRyoho.Classes.Collections.Tracks extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Track
  url: "/data/tracks/"



  #
  #  Fetch
  #
  fetch: (options={}) ->
    success = options.success
    options.reset = true

    # trigger events
    this.trigger("fetching")

    # get source ids
    source_ids = OngakuRyoho.SourceManager.collection.get_available_ids()
    source_ids = source_ids.join(",")

    # check options
    options.data ?= {}

    # source_ids, pagination, etc.
    _.extend(options.data, {
      source_ids: source_ids
    })

    _.extend(options.data,
      OngakuRyoho.RecordBox.Filter.model.attributes
    )

    # success
    options.success = (collection, response, request_options) =>
      success(collection, response, request_options) if success
      this.trigger("fetched")

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
  #  Pagination
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



  previous_page: () ->
    return no unless this.page_info().prev

    @page = @page - 1
    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()

    return this.fetch()



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
