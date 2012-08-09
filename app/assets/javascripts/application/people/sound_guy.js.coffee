class OngakuRyoho.Classes.People.SoundGuy

  constructor: () ->
    @shuffle_track_history = []
    @shuffle_track_history_index = 0



  #
  #  Go to work
  #
  go_to_work: () =>
    @machine = new OngakuRyoho.Classes.Machinery.Audio
    @machine.person = this
    @machine.setup()

    # get set
    this.apply_settings_from_local_storage();
    this.check_the_lights()



  #
  #  Check the lights
  #
  check_the_lights: () =>
    this.set_shuffle()
    this.set_repeat()
    this.set_mute()



  #
  #  Settings in local storage
  #
  save_settings_in_local_storage: () =>
    settings = _.pick(
      OngakuRyoho.Controller.attributes,
      "shuffle", "repeat", "mute", "volume"
    )

    # store settings
    window.localStorage.setItem(
      "controller_settings",
      JSON.stringify(settings)
    )



  apply_settings_from_local_storage: () =>
    item = window.localStorage.getItem("controller_settings")

    # check
    return unless item

    # parse item
    settings = JSON.parse(item)

    # apply settings
    OngakuRyoho.Controller.set(settings)



  #
  #  Current track
  #
  get_current_track: () =>
    source = @machine.get_active_source()
    return (if source then source.track else null)



  #
  #  Set volume
  #
  set_volume: () =>
    volume = OngakuRyoho.Controller.get("volume")

    # needed elements
    $knob = OngakuRyoho.ControllerView.$control("knob", "volume", ".it div")

    # rotate volume button
    angle = ((volume - 50) * 135) / 50
    Helpers.css.rotate($knob, angle)

    # sound
    unless OngakuRyoho.Controller.get("mute")
      @machine.set_volume(volume / 100)

    # save
    this.save_settings_in_local_storage()



  #
  #  Set mute
  #
  set_mute: () =>
    state = OngakuRyoho.Controller.get("mute")

    # needed elements
    $light = OngakuRyoho.ControllerView.$control("switch", "volume", ".light")

    # calculate volume
    original_volume = (OngakuRyoho.Controller.get("volume") / 100)
    volume = (if state then 0 else original_volume)

    # light
    if state
      $light.removeClass("on")
    else
      $light.addClass("on")

    # sound
    @machine.set_volume(volume)

    # save
    this.save_settings_in_local_storage()



  #
  #  Set shuffle
  #
  set_shuffle: () =>
    state = OngakuRyoho.Controller.get("shuffle")

    # needed elements
    $light = OngakuRyoho.ControllerView.$control("switch", "shuffle", ".light")

    # reset shuffle history?
    this.reset_shuffle_history() if state

    # light
    if state
      $light.addClass("on")
    else
      $light.removeClass("on")

    # save
    this.save_settings_in_local_storage()



  #
  #  Set repeat
  #
  set_repeat: () =>
    state = OngakuRyoho.Controller.get("repeat")

    # needed elements
    $light = OngakuRyoho.ControllerView.$control("switch", "repeat", ".light")

    # light
    if state
      $light.addClass("on")
    else
      $light.removeClass("on")

    # save
    this.save_settings_in_local_storage()



  #
  #  Insert track
  #
  insert_track: (track) =>
    # destroy current sources
    @machine.destroy_all_sources()

    # track attributes
    track_attributes = track.toJSON()

    # this sound guy
    this_sound_guy = this

    # create new source
    @machine.create_new_source(track, true)

    # controller attributes
    controller_attributes =
      time:        0
      duration:    0

      artist:      track_attributes.artist
      title:       track_attributes.title
      album:       track_attributes.album

      now_playing: "#{track_attributes.artist} - <strong> #{track_attributes.title}</strong>"

    # set controller attributes
    OngakuRyoho.Controller.set(controller_attributes)

    # add playing class to track
    OngakuRyoho.PlaylistView.track_list_view.machine.add_playing_class_to_track(track)

    # document title
    OngakuRyoho.ControllerView.machine.set_current_track_in_document_title()



  #
  #  Sound events
  #
  # TODO: sound_whileloading: () =>
  #   percent_loaded = ((@current_sound.bytesLoaded / @current_sound.bytesTotal) * 100) + '%'
  #
  #   @controller_view.$progress_bar
  #     .children('.progress.loader')
  #     .css('width', percent_loaded)



  #
  #  Select new track
  #
  select_new_track: () =>
    shuffle = OngakuRyoho.Controller.get("shuffle")
    tracks = OngakuRyoho.Tracks.models

    # select
    if shuffle
      track = _.shuffle(tracks)[0]
    else
      track = tracks[0]

    # check
    return unless track

    # push to history stack if shuffle
    @shuffle_track_history.push(track.get("id")) if shuffle

    # insert track
    this.insert_track(track)

    # set elements
    $playpause_button_light = OngakuRyoho.ControllerView.$control("button", "play-pause", ".light")

    # turn the play button light on
    $playpause_button_light.addClass("on")



  #
  #  Play track
  #
  play_track: () =>
    if @machine.get_active_source()
      this.play_current_track()
    else
      this.select_new_track()



  play_current_track: () =>
    source = @machine.get_active_source()

    # check
    return unless source

    # play/resume
    @machine.play(source)

    # set document title
    OngakuRyoho.ControllerView.machine.set_current_track_in_document_title()



  #
  #  Pause track
  #
  pause_current_track: () =>
    source = @machine.get_active_source()

    # check
    return unless source

    # pause
    @machine.pause(source)

    # set document title
    Helpers.set_document_title(Helpers.original_document_title)



  #
  #  Previous track
  #
  select_previous_track: () =>
    source = @machine.get_active_source()
    return unless source

    # set
    shuffle = OngakuRyoho.Controller.get("shuffle")
    shuffle_th = @shuffle_track_history_index
    console.log "prev", shuffle_th

    # if shuffle
    if shuffle
      return if shuffle_th is 0

      track = OngakuRyoho.Tracks.find (t) => t.get("id") is @shuffle_track_history[shuffle_th - 1]
      @shuffle_track_history_index-- if track

    # otherwise
    else
      tracks = OngakuRyoho.Tracks.models
      track_index = _.indexOf(tracks, source.track) - 1
      track_index = (tracks.length - 1) if track_index < 0
      track = tracks[track_index]

    # insert track if any
    this.insert_track(track) if track



  #
  #  Next track
  #
  select_next_track: () =>
    source = @machine.get_active_source()
    return this.select_new_track() unless source

    # set
    shuffle = OngakuRyoho.Controller.get("shuffle")
    shuffle_th = @shuffle_track_history_index
    console.log "next", shuffle_th

    # if shuffle
    if shuffle
      if shuffle_th < @shuffle_track_history.length - 1
        track = OngakuRyoho.Tracks.find (t) => t.get("id") is @shuffle_track_history[shuffle_th + 1]

      else
        track = _.shuffle(OngakuRyoho.Tracks.reject((t) =>
          return _.include(@shuffle_track_history, t.get("id"))
        ))[0]

        unless track
          this.reset_shuffle_history()
          this.select_next_track()
          return

        @shuffle_track_history.push(track.get("id"))

      @shuffle_track_history_index++

    # otherwise
    else
      tracks = OngakuRyoho.Tracks.models
      track_index = _.indexOf(tracks, source.track) + 1
      track_index = 0 if track_index >= tracks.length
      track = tracks[track_index]

    # insert track if any
    this.insert_track(track) if track



  #
  #  Reset shuffle history
  #
  reset_shuffle_history: () =>
    @shuffle_track_history = []
