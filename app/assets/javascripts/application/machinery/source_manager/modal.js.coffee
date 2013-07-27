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

    # fetch and then remove css class
    Helpers.promise_fetch(OngakuRyoho.SourceManager.collection)
      .then () ->
        OngakuRyoho.SourceManager.collection.update_tracks_on_all()
      .then (changes) ->
        unless _.contains(changes, true)
          OngakuRyoho.RecordBox.Tracks.collection.fetch()

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

    # action
    if $form.attr("data-action") is "CREATE"
      OngakuRyoho.SourceManager.collection.create(attrs, {
        wait: true,
        success: () ->
          OngakuRyoho.SourceManager.view.render()
          OngakuRyoho.SourceManager.view.add_working_class_to_refresh_sources_button()
          OngakuRyoho.SourceManager.collection.update_tracks_on_all()
            .then (changes) ->
              unless _.contains(changes, true)
                OngakuRyoho.RecordBox.Tracks.collection.fetch()
              OngakuRyoho.SourceManager.view.render()
      })

      OngakuRyoho.SourceManager.view.show_window("main")
      OngakuRyoho.SourceManager.view.render()
      OngakuRyoho.SourceManager.view.add_working_class_to_refresh_sources_button()
