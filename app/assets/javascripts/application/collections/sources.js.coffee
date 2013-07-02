class OngakuRyoho.Classes.Collections.Sources extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Source,
  url: "/api/sources/",


  get_available: () ->
    this.where({ available: true })


  get_available_ids: () ->
    _.map(this.get_available(), (s) -> s.id)


  fetch: (options={}) ->
    this.is_fetching = true
    success = options.success

    options.reset = true
    options.success = () =>
      success() if success
      this.is_fetching = false

    Backbone.Collection.prototype.fetch.call(this, options)


  #
  #  Update tracks
  #
  update_tracks_on_all: () =>
    available_sources = this.get_available()

    # check
    return if available_sources.length is 0

    # busy state
    this.is_updating = true

    # make a promise
    promise = new RSVP.Promise()

    # queue
    queue = _.map(available_sources, (source, idx) =>
      source.update_tracks()
    )

    # add message
    message = new OngakuRyoho.Classes.Models.Message({
      text: "Updating tracks database",
      loading: true
    })

    OngakuRyoho.MessageCenter.collection.add(message)

    # exec
    RSVP.all(queue).then () =>
      OngakuRyoho.MessageCenter.collection.remove(message)
      promise.resolve()
      this.is_updating = false
      message = null

    # return
    promise
