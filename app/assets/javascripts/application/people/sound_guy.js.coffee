class OngakuRyoho.Classes.People.SoundGuy

  constructor: () ->
    @shuffle_track_history = []
    @shuffle_track_history_index = 0



  #
  #  Learn basics
  #
  learn_basics: (necessary_materials) =>
    $.extend(this, necessary_materials)

    # setup audio
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
    settings = _.pick(@controller.attributes, "shuffle", "repeat", "mute", "volume")

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
    @controller.set(settings)



  #
  #  Current track
  #
  get_current_track: () =>
    if @machine.sources.length
      _.last(@machine.sources).track
    else
      null



  #
  #  Set volume
  #
  set_volume: () =>
    volume = @controller.get("volume")

    # rotate volume button
    angle = ((volume - 50) * 135) / 50
    Helpers.css.rotate(@controller_view.$el.find(".controls a .knob.volume .it div"), angle)

    # sound
    @machine.nodes.volume.gain.value = (volume / 100)

    # save
    this.save_settings_in_local_storage()



  #
  #  Set mute
  #
  set_mute: () =>
    $light = @controller_view.$el.find(".controls a .switch.volume .light")
    state = @controller.get("mute")
    volume = (@controller.get("volume") / 100)

    # light
    if state
      $light.removeClass("on")
    else
      $light.addClass("on")

    # sound
    @machine.nodes.volume.gain.value = if state then 0 else volume

    # save
    this.save_settings_in_local_storage()



  #
  #  Set shuffle
  #
  set_shuffle: () =>
    $light = @controller_view.$el.find('.controls a .switch.shuffle .light')
    state = @controller.get('shuffle')

    # reset shuffle history?
    this.reset_shuffle_history() if state

    # light
    if state
      $light.addClass('on')
    else
      $light.removeClass('on')

    # save
    this.save_settings_in_local_storage()



  #
  #  Set repeat
  #
  set_repeat: () =>
    $light = @controller_view.$el.find('.controls a .switch.repeat .light')
    state = @controller.get('repeat')

    # light
    if state
      $light.addClass('on')
    else
      $light.removeClass('on')

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

      now_playing: track_attributes.artist + ' - <strong>' + track_attributes.title + '</strong>'

    # set controller attributes
    @controller.set(controller_attributes)

    # add playing class to track
    @playlist_view.track_list_view.machine.add_playing_class_to_track(track)

    # document title
    @controller_view.machine.set_current_track_in_document_title()



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
    shuffle = @controller.get('shuffle')
    $tracks = @playlist_view.track_list_view.$el.find('.track')

    # select
    if shuffle
      $track = $(_.shuffle($tracks)[0])
    else
      $track = $tracks.first()

    # get model
    track = ℰ.Tracks.getByCid($track.attr('rel'))

    # push to history stack if shuffle
    @shuffle_track_history.push(track.get('id')) if shuffle

    # insert track
    this.insert_track(track)

    # set elements
    $playpause_button_light = @controller_view.$el.find(".controls a .button.play-pause .light")

    # turn the play button light on
    $playpause_button_light.addClass("on")



  #
  #  Play track
  #
  play_track: () =>
    if @machine.sources.length
      this.play_current_track()
    else
      this.select_new_track()



  play_current_track: () =>
    source = _.last(@machine.sources)

    # check
    return unless source

    # play/resume
    @machine.play(source)

    # set document title
    @controller_view.machine.set_current_track_in_document_title()



  #
  #  Pause track
  #
  pause_current_track: () =>
    source = _.last(@machine.sources)

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
    return unless @machine.sources.length

    # set
    shuffle = @controller.get('shuffle')
    shuffle_th = @shuffle_track_history_index

    $tracks = @playlist_view.track_list_view.$el.find('.track')

    # if shuffle
    if shuffle
      return if shuffle_th is 0

      track = @tracks.find (t) => t.get('id') is @shuffle_track_history[shuffle_th - 1]

      if track
        @shuffle_track_history_index--
        $track = $tracks.filter('[rel="' + track.cid + '"]')

    # otherwise
    else
      $track = $tracks.filter('.playing').prev('.track')
      $track = $tracks.last() unless $track.length

    # trigger dblclick on track (in playlist)
    $track.trigger('dblclick') if $track



  #
  #  Next track
  #
  select_next_track: () =>
    return this.select_new_track() unless @machine.sources.length

    # set
    shuffle = @controller.get('shuffle')
    shuffle_th = @shuffle_track_history_index

    $tracks = @playlist_view.track_list_view.$el.find('.track')

    # if shuffle
    if shuffle
      if shuffle_th < @shuffle_track_history.length - 1
        track = @tracks.find (t) => t.get('id') is @shuffle_track_history[shuffle_th + 1]

      else
        track = _.shuffle(@tracks.reject((t) =>
          return _.include(@shuffle_track_history, t.get('id'))
        ))[0]

        unless track
          this.reset_shuffle_history()
          this.select_next_track()
          return

        @shuffle_track_history.push(track.get('id'))

      @shuffle_track_history_index++
      $track = $tracks.filter("[rel=\"#{track.cid}\"]")

    # otherwise
    else
      $track = $tracks.filter('.playing').next('.track')
      $track = $tracks.first() unless $track.length

    # trigger dblclick on track (in playlist)
    $track.trigger('dblclick') if $track



  #
  #  Reset shuffle history
  #
  reset_shuffle_history: () =>
    @shuffle_track_history = []
