class OngakuRyoho.Classes.People.KeyMaster

  constructor: () ->
    @state = { ready: false }



  #
  #  Go to work
  #
  go_to_work: () ->
    # TODO



  #
  #  Filter
  #
  filter_extra_search_field_bind: () ->
    Mousetrap.bind("backspace", this.filter_extra_search_field_backspace, "keyup")


  filter_extra_search_field_unbind: () ->
    Mousetrap.unbind("backspace", "keyup")


  filter_extra_search_field_backspace: (e) ->
    $input = $(e.target)

    if $input.val().length is 0
      OngakuRyoho.RecordBox.Filter.model.remove_last_filter_in_line()
