class OngakuRyoho.Classes.Collections.Sources extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Source,
  url: "/api/sources/",


  get_available_and_activated: () ->
    this.where({ available: true, activated: true })



  get_available_and_activated_ids: () ->
    _.map(this.get_available_and_activated(), (s) -> s.id)



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
    promise = new RSVP.Promise()
    available_sources = this.where({ available: true })

    # check
    if available_sources.length is 0
      promise.resolve()
      return promise

    # busy state
    this.is_updating = true

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
    RSVP.all(queue).then (changes) =>
      OngakuRyoho.MessageCenter.collection.remove(message)

      if _.contains(changes, true)
        OngakuRyoho.RecordBox.Tracks.collection.fetch()

      promise.resolve(changes)

      this.is_updating = false
      message = null

    # return
    promise
