class OngakuRyoho.Classes.Collections.Sources extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Source,
  url: "/api/sources/",


  get_available_ids: () ->
    _.map(this.where({ available: true }), (s) -> s.id)


  fetch: (options={}) ->
    options.reset = true
    Backbone.Collection.prototype.fetch.call(this, options)


  #
  #  Process & Check
  #
  process_and_check_sources: () =>
    promise = new RSVP.Promise()
    @changes = false

    this.process_sources()
      .then(this.check_sources)
      .then () =>
        this.reload() if @changes
        promise.resolve()

    return promise


  reload: () ->
    OngakuRyoho.RecordBox.Tracks.collection.fetch()


  process_sources: () =>
    promise = new RSVP.Promise()

    # find
    unprocessed_sources = _.filter(OngakuRyoho.SourceManager.collection.models, (source) ->
      source.get("processed") is false
    )

    # unprocessing function
    unprocessing = _.map(unprocessed_sources, (unprocessed_source, idx) =>
      return this.process_source(unprocessed_source)
    )

    # add message
    unprocessing_message = new OngakuRyoho.Classes.Models.Message({
      text: "Processing sources",
      loading: true
    })

    OngakuRyoho.MessageCenter.collection.add(unprocessing_message)

    # exec
    RSVP.all(unprocessing).then (changes_array) =>
      @changes = _.contains(changes_array, true) if @changes is false
      OngakuRyoho.MessageCenter.collection.remove(unprocessing_message)
      promise.resolve(unprocessed_sources)
      unprocessing_message = null

    # promise
    return promise


  check_sources: (sources_to_skip=[]) =>
    promise = new RSVP.Promise()

    # find
    sources_to_check = _.difference(@models, sources_to_skip)

    # checking function
    checking = _.map(sources_to_check, (source_to_check, idx) =>
      return this.check_source(source_to_check)
    )

    # add message
    checking_message = new OngakuRyoho.Classes.Models.Message({
      text: "Checking out sources",
      loading: true
    })

    OngakuRyoho.MessageCenter.collection.add(checking_message)

    # exec
    RSVP.all(checking).then (changes_array) =>
      @changes = _.contains(changes_array, true) if @changes is false
      OngakuRyoho.MessageCenter.collection.remove(checking_message)
      promise.resolve(sources_to_check)
      checking_message = null

    # promise
    return promise


  process_source: (source) ->
    promise = new RSVP.Promise()
    url = this.url + source.get("id") + "/process"
    original_updated_at = source.get("updated_at")

    $.get(url, (response) ->
      changed = false

      unless response.processing
        promise.resolve(changed)
      else
        source.poll_for_busy_state().then () ->
          changed = true if source.get("updated_at") isnt original_updated_at
          promise.resolve(changed)
    )

    return promise


  check_source: (source) ->
    promise = new RSVP.Promise()
    url = this.url + source.get("id") + "/check"
    original_updated_at = source.get("updated_at")

    $.get(url, (response) ->
      changed = false

      unless response.checking
        promise.resolve(changed)
      else
        source.poll_for_busy_state().then () ->
          changed = true if source.get("updated_at") isnt original_updated_at
          promise.resolve(changed)
    )

    return promise
