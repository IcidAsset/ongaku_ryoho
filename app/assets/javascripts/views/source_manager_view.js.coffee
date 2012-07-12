class OngakuRyoho.Views.SourceManager extends Backbone.View
  
  #
  #  Events
  #
  events:
    "click .background" : "hide"



  #
  #  Initialize
  #
  initialize: () =>
    $source_list_view = this.$el.find(".window.main section")
    $add_section      = this.$el.find(".window.add section")

    # main section
    @source_list_view = new OngakuRyoho.Views.SourceList({ el: $source_list_view  })

    # add section
    this.setup_add_section($add_section)



  #
  #  Check sources
  #
  check_sources: () =>
    this.find_sources_to_process()



  find_sources_to_process: () =>
    # find
    unprocessed_sources = _.filter(Sources.models, (source) ->
      source.get("status").indexOf("unprocessed") isnt -1
    )
    
    # check
    if unprocessed_sources.length is 0
      return this.find_sources_to_check()

    # unprocessing function
    unprocessing = _.map(unprocessed_sources, (unprocessed_source, idx) =>
      return () => this.process_source(unprocessed_source)
    )

    # add message
    unprocessing_message = new OngakuRyoho.Models.Message({
      text: "Processing sources",
      loading: true
    })

    Messages.add(unprocessing_message)

    # exec
    Deferred.chain(unprocessing).next(() =>
      @requires_reload = true
      this.find_sources_to_check(unprocessed_sources)

      Messages.remove(unprocessing_message)
    )



  find_sources_to_check: (unprocessed_sources=[]) =>
    # after
    after = () =>
      Tracks.fetch()
      Sources.fetch()
      
      @requires_reload = false

    # find
    sources_to_check = _.difference(Sources.models, unprocessed_sources)

    # check
    if sources_to_check.length is 0
      if @requires_reload
        return after()
      else
        return false

    # checking function
    checking = _.map(sources_to_check, (source_to_check, idx) =>
      return () => this.check_source(source_to_check)
    )

    # add message
    checking_message = new OngakuRyoho.Models.Message({
      text: "Checking out sources",
      loading: true
    })

    Messages.add(checking_message)

    # exec
    Deferred.chain(checking).next((x) ->
      if _.has(arguments[0], "changed")
        changes = _.pluck(arguments, "changed")
      else
        changes = _.map(arguments, (x) -> return x[0].changed)

      # changes?
      changes = _.include(changes, true)

      # exec after function if needed
      after() if changes or SourceManagerView.requires_reload

      # remove message
      Messages.remove(checking_message)
    )



  process_source: (source) ->
    def = new Deferred()

    $.get("/sources/" + source.get("_id") + "/process",
      (response) -> def.call(response)
    )

    return def



  check_source: (source) ->
    def = new Deferred()

    $.get("/sources/" + source.get("_id") + "/check",
      (response) -> def.call(JSON.parse(response))
    )

    return def



  #
  #  Setup add forms
  #
  setup_add_section: ($add_section) =>
    $select = $add_section.find(".select-wrapper select")
    $forms_wrapper = $add_section.find(".forms-wrapper")

    # when the "source selection" has changed
    $select.on("change", () ->
      $t    = $(this)
      klass = "." + $t.val()

      $forms.not(klass).hide(0)
      $forms.filter(klass).show(0)
    )

    # load forms
    $.get("/servers/new", (servers_form) ->
      $forms_wrapper.append(servers_form)
      $forms_wrapper.children("form").first().show(0)
    )



  #
  #  Show & Hide
  #
  show: () =>
    this.$el.show(0)



  hide: () =>
    this.$el.hide(0)
