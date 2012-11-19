class OngakuRyoho.Classes.Collections.Sources extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Source,
  url: "/sources/"



  #
  #  Process & Check
  #
  process_and_check_sources: (reload_anyway=false) =>
    dfd = new Deferred()

    Deferred
      .next((a) => this.process_sources(false))
      .next((b) => this.check_sources(false, b))
      .next((c) =>
        this.reload() if @requires_reload or reload_anyway
        dfd.call()
      )

    return dfd



  reload: () ->
    OngakuRyoho.Playlist.Tracks.collection.fetch()
    OngakuRyoho.SourceManager.collection.fetch()

    @requires_reload = false



  process_sources: (reload=true) ->
    dfd = new Deferred()

    # find
    unprocessed_sources = _.filter(OngakuRyoho.SourceManager.collection.models, (source) ->
      source.get("status").indexOf("unprocessed") isnt -1
    )

    # quit when there are no sources to process
    return if unprocessed_sources.length is 0

    # unprocessing function
    unprocessing = _.map(unprocessed_sources, (unprocessed_source, idx) =>
      return () => this.process_source(unprocessed_source)
    )

    # add message
    unprocessing_message = new OngakuRyoho.Classes.Models.Message({
      text: "Processing sources",
      loading: true
    })

    OngakuRyoho.MessageCenter.collection.add(unprocessing_message)

    # exec
    Deferred.chain(unprocessing).next(() =>
      OngakuRyoho.MessageCenter.collection.remove(unprocessing_message)

      if reload
        this.reload()
      else
        @requires_reload = true

      dfd.call(unprocessed_sources)
    )

    # promise
    return dfd



  check_sources: (reload=true, sources_to_skip=[]) ->
    dfd = new Deferred()

    # find
    sources_to_check = _.difference(@models, sources_to_skip)

    # quit when there are no sources to check
    return if sources_to_check.length is 0

    # checking function
    checking = _.map(sources_to_check, (source_to_check, idx) =>
      return () => this.check_source(source_to_check)
    )

    # add message
    checking_message = new OngakuRyoho.Classes.Models.Message({
      text: "Checking out sources",
      loading: true
    })

    OngakuRyoho.MessageCenter.collection.add(checking_message)

    # exec
    Deferred.chain(checking).next(() =>
      args = _.compact(arguments)

      if args.length
        if _.has(args[0], "changed")
          changes = _.pluck(args, "changed")
        else
          changes = _.map(args[0], (x) -> return x.changed)
      else
        changes = []

      # changes?
      changes = _.include(changes, true)

      # remove message
      OngakuRyoho.MessageCenter.collection.remove(checking_message)

      # if there are changes
      if changes
        if reload
          this.reload()
        else
          @requires_reload = true

      # continue
      dfd.call(sources_to_check)
    )

    # promise
    return dfd



  process_source: (source) ->
    dfd = new Deferred()

    $.get("/sources/" + source.get("id") + "/process",
      (response) -> dfd.call(JSON.parse(response))
    )

    return dfd



  check_source: (source) ->
    dfd = new Deferred()

    $.get("/sources/" + source.get("id") + "/check",
      (response) -> dfd.call(JSON.parse(response))
    )

    return dfd
