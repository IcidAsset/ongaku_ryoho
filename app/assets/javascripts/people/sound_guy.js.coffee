class OngakuRyoho.People.SoundGuy
  
  constructor: () ->
    @shuffle_track_history = []
    @shuffle_track_history_index = 0



  #
  #  Learn basics
  #
  learn_basics: (necessary_materials) =>
    $.extend(this, necessary_materials)

    this.apply_settings_from_cookie();
    this.setup_soundboard()
    this.check_the_lights()



  #
  #  Check the lights
  #
  check_the_lights: () =>
    this.set_shuffle()
    this.set_repeat()
    this.set_mute()



  #
  #  Settings cookie
  #
  save_settings_in_cookie: () =>
    settings = _.pick(@controller.attributes, 'shuffle', 'repeat', 'mute', 'volume')
  
    # set cookie
    $.cookie(
      'controller_settings',
      JSON.stringify(settings),
      { raw: true, expires: 365, path: '/' }
    )



  apply_settings_from_cookie: () =>
    # find cookie
    cookie = $.cookie('controller_settings')
  
    # check
    return unless cookie
  
    # parse cookie
    settings = $.parseJSON( cookie )
  
    # apply settings
    @controller.set(settings)



  #
  #  Setups
  #
  setup_soundboard: () =>
    # ready state
    @sound_manager = { ready: false }

    # sound manager settings
    soundManager.url = soundManagerFlashURL
    soundManager.flashVersion = 9
    soundManager.useFlashBlock = false
    soundManager.preferFlash = true
    soundManager.debugMode = false
    soundManager.useFastPolling = true
    soundManager.flash9Options = { usePeakData: true }

    # when sound manager is ready
    soundManager.onready () =>
     @sound_manager.ready = true



  #
  #  Current track
  #
  get_current_track: () =>
    if @current_sound
      track = Tracks.find (track) => track.get('_id') is @current_sound.sID
    else
      null



  #
  #  Set volume
  #
  set_volume: () =>
    volume = @controller.get('volume')

    # rotate volume button
    angle = ((volume - 50) * 135) / 50
    helpers.css.rotate(@controller_view.$el.find('.controls a .knob.volume .it div'), angle)

    # sound
    @current_sound.setVolume(volume) if @current_sound

    # save
    this.save_settings_in_cookie()



  #
  #  Set mute
  #
  set_mute: () =>
    $light = @controller_view.$el.find('.controls a .switch.volume .light')
    state = @controller.get('mute')

    # light
    if state
      $light.removeClass('on')
    else
      $light.addClass('on')

    # sound
    if @current_sound
      if state
        @current_sound.mute()
      else
        @current_sound.unmute()

    # save
    this.save_settings_in_cookie()



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
    this.save_settings_in_cookie()



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
    this.save_settings_in_cookie()



  #
  #  Insert track
  #
  insert_track: (track) =>
    # destroy current sound
    soundManager.destroySound(@current_sound.sID) if @current_sound

    # track attributes
    track_attributes = track.toJSON()

    # this sound guy
    this_sound_guy = this

    # create sound
    new_sound = soundManager.createSound
      id:             track_attributes._id
      url:            track_attributes.url

      volume:         0
      autoLoad:       true
      autoPlay:       true
      stream:         true

      onfinish:       this_sound_guy.sound_onfinish
      onload:         this_sound_guy.sound_onload
      onplay:         this_sound_guy.sound_onplay
      whileloading:   this_sound_guy.sound_whileloading
      whileplaying:   this_sound_guy.sound_whileplaying

    # current track
    @current_sound = new_sound

    # volume
    this.set_mute()
    this.set_volume()

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
    @playlist_view.track_list_view.add_playing_class_to_track(track)

    # document title
    @controller_view.set_current_track_in_document_title()



  #
  #  Sound events
  #
  sound_onfinish: () =>
    repeat = @controller.get('repeat')

    # action
    if repeat
      @playlist_view.track_list_view.$el.find('.track.playing').trigger('dblclick')
    else
      this.select_next_track()



  sound_onload: () =>
    @controller.set({ duration: @current_sound.duration })



  sound_onplay: () =>
    this.set_mute()
    this.set_volume()



  sound_whileloading: () =>
    percent_loaded = ((@current_sound.bytesLoaded / @current_sound.bytesTotal) * 100) + '%'

    @controller_view.$progress_bar
      .children('.progress.loader')
      .css('width', percent_loaded)



  sound_whileplaying: () =>
    @controller.set({ time: @current_sound.position })
    @visualizations_view.visualize('peak_data', @current_sound.peakData)



  #
  #  Select new track
  #
  select_new_track: () =>
    shuffle = @controller.get('shuffle')
    $tracks = @playlist_view.track_list_view.$el.find('.track')

    # select
    if shuffle
      $track = $( _.shuffle($tracks)[0] )
    else
      $track = $tracks.first()

    # get model
    track = Tracks.getByCid( $track.attr('rel') )

    # push to history stack if shuffle
    @shuffle_track_history.push(track.get('_id')) if shuffle

    # insert track
    this.insert_track( track )



  #
  #  Play track
  #
  play_track: () =>
    if @current_sound
      this.play_current_track()
    else
      this.select_new_track()



  play_current_track: () =>
    return unless @current_sound

    # mute track if the controller says so
    soundManager.mute(@current_sound.sID) if @controller.get('mute')

    # play/resume
    if @current_sound.paused
      soundManager.resume(@current_sound.sID)
    else
      soundManager.play(@current_sound.sID)

    # set document title
    @controller_view.set_current_track_in_document_title()



  #
  #  Pause track
  #
  pause_current_track: () =>
    return unless @current_sound

    # pause
    soundManager.pause(@current_sound.sID)

    # set document title
    helpers.set_document_title(helpers.original_document_title)



  #
  #  Stop track
  #
  stop_current_track: () =>
    return unless @current_sound

    # stop
    soundManager.stop(this.current_sound.sID)

    # set document title
    helpers.set_document_title(helpers.original_document_title)

    # set time on controller
    @controller.set({ time: 0 })



  #
  #  Previous track
  #
  select_previous_track: () =>
    return unless @current_sound

    # set
    shuffle = @controller.get('shuffle')
    shuffle_th = @shuffle_track_history_index

    $tracks = @playlist_view.track_list_view.$el.find('.track')

    # if shuffle
    if shuffle
      return if shuffle_th is 0

      track = @tracks.find (t) => t.get('_id') is @shuffle_track_history[shuffle_th - 1]

      if track
        @shuffle_track_history_index--
        $track = $tracks.filter('[rel="' + track.cid + '"]')

    # otherwise
    else
      $track = $tracks.filter('.playing').prev('.track')
      $track = $tracks.last() unless $track.length

    # trigger dblclick on track (in playlist)
    $track.trigger('dblclick')



  #
  #  Next track
  #
  select_next_track: () =>
    return this.select_new_track() unless @current_sound

    # set
    shuffle = @controller.get('shuffle')
    shuffle_th = @shuffle_track_history_index

    $tracks = @playlist_view.track_list_view.$el.find('.track')

    # if shuffle
    if shuffle
      if shuffle_th < @shuffle_track_history.length - 1
        track = @tracks.find (t) => t.get('_id') is @shuffle_track_history[shuffle_th + 1]

      else
        track = _.shuffle(@tracks.reject((t) =>
          return _.include(@shuffle_track_history, t.get('_id'))
        ))[0]

        unless track
          this.reset_shuffle_history()
          this.select_next_track()
          return

        @shuffle_track_history.push(track.get('_id'))

      @shuffle_track_history_index++
      $track = $tracks.filter('[rel="' + track.cid + '"]')

    # otherwise
    else
      $track = $tracks.filter('.playing').next('.track')
      $track = $tracks.first() unless $track.length

    # trigger dblclick on track (in playlist)
    $track.trigger('dblclick')



  #
  #  Reset shuffle history
  #
  reset_shuffle_history: () =>
    @shuffle_track_history = []
