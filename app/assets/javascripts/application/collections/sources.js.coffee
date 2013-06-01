class OngakuRyoho.Classes.Collections.Sources extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Source,
  url: "/api/sources/",


  get_available_ids: () ->
    _.map(this.where({ available: true }), (s) -> s.id)


  fetch: (options={}) ->
    options.reset = true
    Backbone.Collection.prototype.fetch.call(this, options)


  #
  #  Process
  #
  process_all: () =>
    promise = new RSVP.Promise()

    # queue
    queue = _.map(@models, (source, idx) =>
      source.process()
    )

    # add message
    message = new OngakuRyoho.Classes.Models.Message({
      text: "Processing sources",
      loading: true
    })

    OngakuRyoho.MessageCenter.collection.add(message)

    # exec
    RSVP.all(checking).then (changes_array) =>
      OngakuRyoho.MessageCenter.collection.remove(message)
      promise.resolve()
      message = null

    # return
    promise
