class OngakuRyoho.Classes.Engines.Queue

  # select_new_track       -> shift next array
  # select_next_track      -> shift next array
  # select_previous_track  -> go back in history and recalculate next

  setup: () ->
    @properties =
      history: []
      current: null
      user_next: []
      computed_next: []
      combined_next: []



  add_to_next: (track_id) ->
    @properties.user_next.push(track_id)



  set_combined_next: () ->
    # next = user_next
    # + the ones left in the computed_next array
    # + X new ones
    #
    # -> resets when toggle shuffle



  set_current: () ->
    # move previous current to history
    # set new current



  clear_history: () ->
    @properties.history.length = 0
