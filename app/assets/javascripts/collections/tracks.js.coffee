class OngakuRyoho.Collections.Tracks extends Backbone.Collection

  model: OngakuRyoho.Models.Track
  url: "/tracks/"


  #
  #  Initialize
  #
  initialize: () =>
    @page = 1
    @per_page = 500
    @filter = ""
    @sort_by = "artist"
    @sort_direction = "asc"
    
    # special filters
    @favourites = off


  #
  #  Fetch
  #
  fetch: (options={}) =>
    success = options.success

    # show message
    message = new OngakuRyoho.Models.Message
      text: "Loading tracks",
      loading: true

    Messages.add(message)

    # trigger event
    this.trigger("fetching")

    # pagination and filter
    options.data ?= {}
    $.extend options.data, {
      page: @page,
      per_page: @per_page,
      filter: @filter,
      sort_by: @sort_by,
      sort_direction: @sort_direction,
      
      favourites: @favourites
    }

    # success
    options.success = (response) =>
      success(this, response) if success
      SoundGuy.reset_shuffle_history()
      this.trigger("fetched")
      Messages.remove(message)

    # call
    return Backbone.Collection.prototype.fetch.call(this, options)


  #
  #  Parse
  #
  parse: (response) =>
    @page = response.page
    @per_page = response.per_page
    @total = response.total
    return response.models


  #
  #  Page info
  #
  page_info: () =>
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
  previous_page: () =>
    return no unless this.page_info().prev

    @page = @page - 1 
    return this.fetch()


  #
  #  Next page
  #
  next_page: () =>
    return no unless this.page_info().next

    @page = @page + 1
    return this.fetch()
