class OngakuRyoho.Classes.Collections.Sources extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Source,
  url: "/api/sources/",


  get_available_ids: () ->
    _.map(this.where({ available: true }), (s) -> s.id)


  fetch: (options={}) ->
    options.reset = true
    Backbone.Collection.prototype.fetch.call(this, options)


  #
  #  Update tracks
  #
  update_tracks_on_all: () =>
    return if @models.length is 0

    # make a promise
    promise = new RSVP.Promise()

    # queue
    queue = _.map(@models, (source, idx) =>
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
      message = null

    # return
    promise
