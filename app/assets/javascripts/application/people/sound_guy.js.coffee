class OngakuRyoho.Classes.People.SoundGuy

  constructor: () ->
    @shuffle_track_history = []
    @shuffle_track_history_index = 0



  #
  #  Go to work
  #
  go_to_work: () ->
    @audio_engine = OngakuRyoho.Engines.Audio

    # queue
    @queue = OngakuRyoho.Engines.Queue
    @queue.setup()

    # his mixing console
    @mixing_console = OngakuRyoho.MixingConsole

    # part two
    this.go_to_work_part_two()



  go_to_work_part_two: () ->
    @audio_engine.setup()

    this.apply_settings_from_local_storage()
    this.check_the_lights()



  #
  #  Check the lights
  #
  check_the_lights: () ->
    this.set_shuffle()
    this.set_repeat()
    this.set_mute()



  #
  #  Settings in local storage
  #
  save_settings_in_local_storage: () ->
    settings = _.pick(
      @mixing_console.model.attributes,
      "shuffle", "repeat", "mute", "volume"
    )

    # store settings
    window.localStorage.setItem(
      "controller_settings",
      JSON.stringify(settings)
    )



  apply_settings_from_local_storage: () ->
    item = window.localStorage.getItem("controller_settings")

    # check
    return unless item

    # parse item
    settings = JSON.parse(item)

    # apply settings
    @mixing_console.model.set(settings)



  #
  #  Current track
  #
  get_current_track: () ->
    source = @audio_engine.get_active_source()
    return (if source then source.track else null)



  #
  #  Set shuffle
  #
  set_shuffle: () =>
    state = @mixing_console.model.get("shuffle")

    # needed elements
    $light = @mixing_console.view.$control("switch", "shuffle", ".light")

    # light
    if state
      $light.addClass("on")
    else
      $light.removeClass("on")

    # reset queue
    this.queue.reset_computed_next()

    # save
    this.save_settings_in_local_storage()



  #
  #  Set repeat
  #
  set_repeat: () =>
    state = @mixing_console.model.get("repeat")

    # needed elements
    $light = @mixing_console.view.$control("switch", "repeat", ".light")

    # light
    if state
      $light.addClass("on")
    else
      $light.removeClass("on")

    # save
    this.save_settings_in_local_storage()



  #
  #  Set volume
  #
  set_volume: () =>
    volume = @mixing_console.model.get("volume")

    # needed elements
    $knob = @mixing_console.view.$control("knob", "volume", ".it div")

    # rotate volume button
    angle = ((volume - 50) * 135) / 50
    Helpers.css.rotate($knob, angle)

    # sound
    unless @mixing_console.model.get("mute")
      @audio_engine.set_volume(volume / 100)

    # save
    this.save_settings_in_local_storage()



  #
  #  Set mute
  #
  set_mute: () =>
    state = @mixing_console.model.get("mute")

    # needed elements
    $light = @mixing_console.view.$control("switch", "volume", ".light")

    # calculate volume
    original_volume = (@mixing_console.model.get("volume") / 100)
    volume = (if state then 0 else original_volume)

    # light
    if state
      $light.removeClass("on")
    else
      $light.addClass("on")

    # sound
    @audio_engine.set_volume(volume)

    # save
    this.save_settings_in_local_storage()



  #
  #  Insert track
  #
  insert_track: (track) ->
    return unless @audio_engine.has_been_setup

    # clear
    @audio_engine.destroy_all_sources()

    # track attributes
    track_attributes = track.toJSON()

    # create new source
    audio = @audio_engine.create_new_source(track, true)
    audio.play()

    # controller attributes
    controller_attributes =
      time:        0
      duration:    0

      artist:      track_attributes.artist
      title:       track_attributes.title
      album:       track_attributes.album

      now_playing: "#{track_attributes.artist} - <strong> #{track_attributes.title}</strong>"

    # set controller attributes
    @mixing_console.model.set(controller_attributes)

    # add playing class to track
    OngakuRyoho.RecordBox.Tracks.machine.add_playing_class_to_track(track)

    # turn the play button light on
    $playpause_button_light = @mixing_console.view.$control("button", "play-pause", ".light")
    $playpause_button_light.addClass("on")

    # document title
    @mixing_console.machine.set_current_track_in_document_title()



  #
  #  Play track
  #
  play_track: () ->
    if @audio_engine.get_active_source()
      this.play_current_track()
    else
      this.select_next_track()



  play_current_track: () ->
    source = @audio_engine.get_active_source()

    # check
    return unless source

    # play/resume
    @audio_engine.play(source)

    # turn the play button light on
    $playpause_button_light = @mixing_console.view.$control("button", "play-pause", ".light")
    $playpause_button_light.addClass("on")

    # set document title
    @mixing_console.machine.set_current_track_in_document_title()



  #
  #  Pause track
  #
  pause_current_track: () ->
    source = @audio_engine.get_active_source()

    # check
    return unless source

    # pause
    @audio_engine.pause(source)

    # turn the play button light off
    $playpause_button_light = @mixing_console.view.$control("button", "play-pause", ".light")
    $playpause_button_light.removeClass("on")

    # set document title
    Helpers.set_document_title(Helpers.original_document_title)



  #
  #  Toggle play/pause
  #
  toggle_playpause: () ->
    source = @audio_engine.get_active_source()

    # toggle
    if source and !@audio_engine.is_paused(source)
      this.pause_current_track()
    else
      this.play_track()



  #
  #  Seek current track
  #
  seek_current_track: (percent) ->
    source = @audio_engine.get_active_source()

    # seek
    @audio_engine.seek(source, percent) if source



  #
  #  Previous track
  #
  select_previous_track: () =>
    track = this.queue.go_backwards()

    # insert track if any
    this.insert_track(track) if track



  #
  #  Next track
  #
  select_next_track: () =>
    track = this.queue.go_forward()

    # insert track if any
    this.insert_track(track) if track
