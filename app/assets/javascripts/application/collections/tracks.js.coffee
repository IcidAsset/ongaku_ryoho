class OngakuRyoho.Classes.Collections.Tracks extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Track
  url: "/api/tracks/"


  get_random_track: (ids_array=[]) ->
    filtered_tracks = this.reject (t) ->
      return _.include(ids_array, t.get("id"))

    # shuffle & get first
    _.shuffle(filtered_tracks)[0]



  #
  #  Fetch
  #
  fetch: (options={}) ->
    success = options.success
    options.reset = true

    # trigger events
    this.trigger("fetching")

    # get source ids
    source_ids = OngakuRyoho.SourceManager.collection.get_available_and_activated_ids()
    source_ids = source_ids.join(",")

    # check options
    options.data ?= {}

    # source_ids, pagination, etc.
    _.extend(options.data,
      { source_ids: source_ids },
      OngakuRyoho.RecordBox.Filter.model.attributes
    )

    # success
    options.success = (collection, response, request_options) =>
      success(collection, response, request_options) if success
      this.trigger("fetched")

    # call super
    Backbone.Collection.prototype.fetch.call(this, options)



  #
  #  Parse
  #
  parse: (response) ->
    OngakuRyoho.RecordBox.Filter.model.set({
      page: response.page
      per_page: response.per_page
      total: response.total
    }, { silent: true })

    response.models



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
    info



  go_to_previous_page: () ->
    return no unless this.page_info().prev

    previous_page_number = OngakuRyoho.RecordBox.Filter.model.get("page") - 1
    OngakuRyoho.RecordBox.Filter.model.set("page", previous_page_number)



  go_to_next_page: () ->
    return no unless this.page_info().next

    next_page_number = OngakuRyoho.RecordBox.Filter.model.get("page") + 1
    OngakuRyoho.RecordBox.Filter.model.set("page", next_page_number)



  #
  #  Toggle favourite on track
  #
  toggle_favourite: (track_id) ->
    track = this.get(track_id)

    if track.get("available")
      this.toggle_favourite_if_available(track)
    else
      this.toggle_favourite_if_unavailable(track)



  toggle_favourite_if_available: (track) ->
    title = track.get("title")
    artist = track.get("artist")
    album = track.get("album")

    # don't link favourite with other tracks
    # if the artist and title are 'unknown'
    if artist.toLowerCase() is "unknown" and title.toLowerCase() is "unknown"
      tracks = [track]
    else
      tracks = this.where({
        title: title,
        artist: artist,
        album: album
      })

    # if favourite
    if track.get("favourite_id")
      OngakuRyoho.RecordBox.Favourites.collection
        .remove_matching_favourites(title, artist, album)

      _.each(tracks, (t) ->
        OngakuRyoho.RecordBox.Tracks.view.$el
          .find(".track[rel='#{t.id}'] > .favourite")
          .attr("data-favourite", "")

        t.set("favourite_id", null)
      )

    # if not a favourite,
    # create one
    else
      OngakuRyoho.RecordBox.Favourites.collection.create({
        title: title,
        artist: artist,
        album: album,
        track_id: track.id
      }, { wait: true })

      _.each(tracks, (t) ->
        OngakuRyoho.RecordBox.Tracks.view.$el
          .find(".track[rel='#{t.id}'] > .favourite")
          .attr("data-favourite", "true")

        t.set("favourite_id", true)
      )



  toggle_favourite_if_unavailable: (track) ->
    OngakuRyoho.RecordBox.Favourites.remove_matching_favourites_by_track_id(track_id)
