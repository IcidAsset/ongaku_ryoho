class OngakuRyoho.Classes.Engines.Queue

  setup: () ->
    @tracks =
      OngakuRyoho.RecordBox.Tracks.collection

    @data =
      history: []
      current: null
      user_next: []
      computed_next: []
      combined_next: []

    @options =
      advance_length: 50



  add_to_next: (track) ->
    @data.user_next.push({ track: track, user: true })
    this.reset_computed_next()



  add_current_to_history: () ->
    @data.history.push(@data.current) if @data.current



  set_next: () ->
    missing_computes = @options.advance_length - @data.computed_next.length

    # check for negatives
    missing_computes = 0 if missing_computes < 0

    # filling in missing computes
    shuffle = OngakuRyoho.MixingConsole.model.get("shuffle")
    if shuffle then this.set_next_shuffle(missing_computes)
    else this.set_next_normal(missing_computes)

    # set combined next
    @data.combined_next = @data.user_next.concat(@data.computed_next)

    # trigger collection reset if needed
    if OngakuRyoho.RecordBox.Tracks.view.mode is "queue"
      @tracks.trigger("reset")


  set_next_normal: (x) ->
    current_track = OngakuRyoho.People.SoundGuy.get_current_track()

    # check
    return if @tracks.length is 0

    # get last track in line
    last_track_in_line_id = if @data.user_next.length > 0 then _.last(@data.user_next).track.id
    else if @data.computed_next.length > 0 then _.last(@data.computed_next).track.id
    else (if current_track then current_track.id else @tracks.last().id)

    # check
    last_track_in_line_id ?= @tracks.first().id

    # loop
    indexof_last = @tracks.indexOf(@tracks.get(last_track_in_line_id))
    indexof_last = 0 if indexof_last < 0
    counter = indexof_last

    for n in [0...x]
      counter = if (counter + 2) > @tracks.models.length then 0
      else counter + 1

      if counter is indexof_last then break
      else @data.computed_next.push({ track: @tracks.at(counter), user: false })



  set_next_shuffle: (x) ->
    for n in [0...x]
      already_selected = @data.user_next.concat(@data.computed_next)
      already_selected = _.map(already_selected, (queue_item) -> queue_item.track.id)
      track = @tracks.get_random_track(already_selected)
      @data.computed_next.push({ track: track, user: false }) if track
      break unless track



  set_current: (map) ->
    @data.current = map



  clear_history: ()       -> this.nullify_array_contents(@data.history)
  clear_user_next: ()     -> this.nullify_array_contents(@data.user_next)
  clear_computed_next: () -> this.nullify_array_contents(@data.computed_next)



  nullify_array_contents: (array) ->
    i = array.length - 1

    while i > 0
      array[i] = null
      --i

    array = _.compact(array)
    array.length = 0



  reset_computed_next: () ->
    this.clear_computed_next()
    this.set_next()



  shift: () ->
    next = @data.combined_next.shift()

    # check
    return null unless next

    # shift related
    if next.user then @data.user_next.shift()
    else @data.computed_next.shift()

    # return
    return next



  pop: () ->
    previous = @data.history.pop()

    # check
    return null unless previous

    # return
    return previous



  go_forward: () ->
    next = this.shift()

    # if empty
    unless next
      console.log("Empty queue")
      return null
    else
      track = next.track

    # add old current to history
    this.add_current_to_history()

    # set current
    this.set_current(next)

    # return
    return track



  go_backwards: () ->
    previous = this.pop()

    # if empty
    unless previous
      console.log("No more tracks in history")
      return null
    else
      track = previous.track

    # add old current to next
    if @data.current
      if @data.current.user then @data.user_next.unshift(@data.current)
      else @data.computed_next.unshift(@data.current)

    # set current
    this.set_current(previous)

    # return
    return track
