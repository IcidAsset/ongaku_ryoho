class OngakuRyoho.Classes.People.KeyMaster

  #
  #  Go to work
  #
  go_to_work: () ->
    ###
      TODO
      -> Bind keyboard events for e.g. play/pause,
         next page in record box, etc.
    ###



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
