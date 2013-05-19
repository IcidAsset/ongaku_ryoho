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
    OngakuRyoho.RecordBox.Filter.model.set({
      page: response.page
      per_page: response.per_page
      total: response.total
    }, { silent: true })
    return response.models



  #
  #  Pagination
  #
  page_info: () ->
    filter = OngakuRyoho.RecordBox.Filter.model
    attr = filter.attributes

    info =
      total: attr.total
      page: attr.page
      per_page: attr.per_page
      pages: Math.ceil(attr.total / attr.per_page)
      prev: false
      next: false

    # max
    if info.total is info.pages * info.per_page
      max = attr.total
    else
      max = Math.min(info.total, info.page * info.per_page)

    # range
    info.range = [(info.page - 1) * info.per_page + 1, max]

    # previous and next
    if info.page > 1
      info.prev = info.page - 1

    if info.page < info.pages
      info.next = info.page + 1

    # return
    return info



  previous_page: () ->
    return no unless this.page_info().prev

    previous_page_number = OngakuRyoho.RecordBox.Filter.model.get("page") - 1
    OngakuRyoho.RecordBox.Filter.model.set("page", previous_page_number)
    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()

    return this.fetch()



  next_page: () ->
    return no unless this.page_info().next

    next_page_number = OngakuRyoho.RecordBox.Filter.model.get("page") + 1
    OngakuRyoho.RecordBox.Filter.model.set("page", next_page_number)
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
