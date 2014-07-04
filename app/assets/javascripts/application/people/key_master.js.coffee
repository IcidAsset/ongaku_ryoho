class OngakuRyoho.Classes.People.KeyMaster

  #
  #  Go to work
  #
  go_to_work: () ->
    Mousetrap.stopCallback = (e, element, combo) ->
      is_input = element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA' || element.isContentEditable

      # do not stop for backspace
      if combo is "backspace"
        return false

      # if the element has the class "mousetrap" then no need to stop
      if (' ' + element.className + ' ').indexOf(' mousetrap ') > -1
        return false

      # stop for input, select, and textarea
      return is_input

    # escape
    Mousetrap.bind("esc", (e) ->
      if OngakuRyoho.SourceManager.view.is_shown()
        OngakuRyoho.SourceManager.view.hide()
    )

    # theater mode
    Mousetrap.bind("t", (e) ->
      u = OngakuRyoho.RecordBox.UserMenu.view.group.machine

      if u.get_theater_mode() is "off"
        u.set_theater_mode_visibility("on")
      else
        u.set_theater_mode_visibility("off")
    )

    # other
    Mousetrap.bind("p", (e) ->
      OngakuRyoho.People.SoundGuy.toggle_playpause()
    )

    Mousetrap.bind("s", (e) ->
      OngakuRyoho.MixingConsole.model.toggle_attribute("shuffle")
    )

    Mousetrap.bind("r", (e) ->
      OngakuRyoho.MixingConsole.model.toggle_attribute("repeat")
    )

    Mousetrap.bind("m", (e) ->
      OngakuRyoho.MixingConsole.model.toggle_attribute("mute")
    )

    Mousetrap.bind("f", (e) ->
      OngakuRyoho.RecordBox.Filter.model.toggle_favourites()
    )

    Mousetrap.bind("space", (e) ->
      OngakuRyoho.RecordBox.Navigation.view.$el.find(".extra-search-field input").focus()
    )

    Mousetrap.bind("left", (e) ->
      OngakuRyoho.People.SoundGuy.select_previous_track()
    )

    Mousetrap.bind("right", (e) ->
      OngakuRyoho.People.SoundGuy.select_next_track()
    )

    Mousetrap.bind("up", (e) ->
      v = OngakuRyoho.MixingConsole.model.get("volume")
      v = Math.ceil(v / 10)
      v = (v + 1) * 10
      v = 100 if v > 100

      OngakuRyoho.MixingConsole.model.set("volume", v)
    )

    Mousetrap.bind("down", (e) ->
      v = OngakuRyoho.MixingConsole.model.get("volume")
      v = Math.ceil(v / 10)
      v = (v - 1) * 10
      v = 0 if v < 0

      OngakuRyoho.MixingConsole.model.set("volume", v)
    )

    Mousetrap.bind("-", (e) ->
      OngakuRyoho.RecordBox.PlaylistMenu.view.toggle()
    )

    Mousetrap.bind("q", (e) ->
      vsm = OngakuRyoho.People.ViewStateManager

      if vsm.get_queue_status()
        vsm.hide_queue()
      else
        vsm.show_queue()
    )



  #
  #  Filter
  #
  filter_extra_search_field_bind: (input_element) ->
    Mousetrap.bind("backspace", this.filter_extra_search_field_backspace, "keyup")
    input_element.addEventListener("keydown", this.filter_extra_search_field_keydown_handler)



  filter_extra_search_field_unbind: (input_element) ->
    Mousetrap.unbind("backspace", "keyup")
    input_element.removeEventListener("keydown", this.filter_extra_search_field_keydown_handler)



  filter_extra_search_field_backspace: (e) ->
    $input = $(e.target)

    if $input.val().length is 0
      if e.target.is_empty
        OngakuRyoho.RecordBox.Filter.model.remove_last_filter_in_line()
      else
        e.target.is_empty = true



  filter_extra_search_field_keydown_handler: (e) ->
    e.target.is_empty = false if e.which isnt 8
