class OngakuRyoho.Classes.Machinery.SourceManager.Modal

  #
  #  Toolbar event handlers
  #
  toolbar_add_source: (e) =>
    @view.show_window("add-source-menu")



  toolbar_refresh_sources: (e) ->
    collection = OngakuRyoho.SourceManager.collection

    # check
    if collection.is_fetching or collection.is_updating
      return

    # add css class
    OngakuRyoho.SourceManager.view.add_working_class_to_refresh_sources_button()

    # fetch sources, update tracks and
    # fetch tracks if necessary
    # -> then remove css class
    Helpers.promise_fetch(OngakuRyoho.SourceManager.collection)
      .then () ->
        OngakuRyoho.SourceManager.collection.update_tracks_on_all()
      .then (changes) ->
        unless _.contains(changes, true)
          OngakuRyoho.RecordBox.Tracks.collection.fetch()
          OngakuRyoho.RecordBox.Playlists.collection.fetch()

        OngakuRyoho.SourceManager.view.remove_working_class_from_refresh_sources_button()



  toolbar_go_back: (e) =>
    @view.show_window(e.currentTarget.getAttribute("data-to"))



  #
  #  Other event handlers
  #
  data_window_click_handler: (e) =>
    @view.show_window(e.currentTarget.getAttribute("data-window"))


  form_submit_handler: (e) ->
    $form = $(e.currentTarget)

    # prevent default
    e.preventDefault()

    # serialize
    attrs = { type: $form.attr("data-type") }
    attrs_array = $form.serializeArray()

    _.each(attrs_array, (v, k) ->
      if (index = v.name.indexOf("[")) isnt -1
        parent_key = v.name.substring(0, index)
        key = v.name.substring(index + 1, v.name.lastIndexOf("]"))
        attrs[parent_key] ?= {}
        attrs[parent_key][key] = v.value
      else
        attrs[v.name] = v.value
    )

    $form.find("input[type=\"checkbox\"]").each(() ->
      name = this.getAttribute("name")
      if (index = name.indexOf("[")) isnt -1
        parent_key = name.substring(0, index)
        key = name.substring(index + 1, name.lastIndexOf("]"))
        attrs[parent_key] ?= {}
        unless attrs[parent_key][key]
          attrs[parent_key][key] = "0"
      else
        unless attrs[name]
          attrs[name] = "0"
    )

    # validate attrs
    errors = []

    validate_object = (obj) ->
      _.each(obj, (v, k) ->
        if typeof(v) is "string"
          errors.push(k) if v.length is 0
        else if typeof(v) is "object"
          validate_object(v)
      )

    validate_object(attrs)

    # errors
    if errors.length > 0
      OngakuRyoho.SourceManager.view.add_error_message_to_shown_window()
      return

    # action -> create
    if $form.attr("data-action") is "CREATE"
      OngakuRyoho.SourceManager.collection.create(attrs, {
        wait: true,
        success: () ->
          OngakuRyoho.SourceManager.view.render("SourceList", "main")
          OngakuRyoho.SourceManager.view.add_working_class_to_refresh_sources_button()
          OngakuRyoho.SourceManager.collection.update_tracks_on_all()
            .then (changes) ->
              unless _.contains(changes, true)
                OngakuRyoho.RecordBox.Tracks.collection.fetch()
              OngakuRyoho.RecordBox.Playlists.collection.fetch()
              OngakuRyoho.SourceManager.view.render("SourceList", "main")
      })

      OngakuRyoho.SourceManager.view.show_window("main")
      OngakuRyoho.SourceManager.view.render("SourceList", "main")
      OngakuRyoho.SourceManager.view.add_working_class_to_refresh_sources_button()

    # action -> update
    else
      source_id = parseInt($form.attr("data-source-id"), 10)
      source = OngakuRyoho.SourceManager.collection.get(source_id)
      attrs.configuration = $.extend({}, source.get("configuration"), attrs.configuration)
      source.save(attrs, {
        success: () ->
          OngakuRyoho.SourceManager.view.render("SourceList", "main")
          OngakuRyoho.SourceManager.view.add_working_class_to_refresh_sources_button()
          OngakuRyoho.SourceManager.collection.update_tracks_on_all()
            .then (changes) ->
              unless _.contains(changes, true)
                OngakuRyoho.RecordBox.Tracks.collection.fetch()
              OngakuRyoho.RecordBox.Playlists.collection.fetch()
              OngakuRyoho.SourceManager.view.render("SourceList", "main")
      })

      OngakuRyoho.SourceManager.view.show_window("main")
      OngakuRyoho.SourceManager.view.render("SourceList", "main")
      OngakuRyoho.SourceManager.view.add_working_class_to_refresh_sources_button()
