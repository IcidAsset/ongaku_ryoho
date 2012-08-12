class OngakuRyoho.Classes.Machinery.Audio

  setup: () =>
    @sources = []
    @audio_elements = []
    @nodes = {}
    @events = {}

    this.set_audio_context()
    this.create_volume_node()
    this.create_analyser_node()
    this.create_audio_elements_container()

    this.start_analysing()



  #
  #  Set audio context
  #
  set_audio_context: () =>
    unless typeof AudioContext is "undefined"
      @ac = new AudioContext()
    else unless typeof webkitAudioContext is "undefined"
      @ac = new webkitAudioContext()
    else
      console.error("Web Audio API not supported!")



  #
  #  Create volume node
  #
  create_volume_node: () =>
    volume_node = @ac.createGainNode()
    volume_node.gain.value = 1

    # connect to destination
    volume_node.connect(@ac.destination)

    # store node
    @nodes.volume = volume_node



  #
  #  Set volume
  #
  set_volume: (value) =>
    @nodes.volume.gain.value = value



  #
  #  Create analyser node
  #
  create_analyser_node: () =>
    analyser_node = @ac.createAnalyser()
    analyser_node.fftSize = 1024

    # connect to volume node
    analyser_node.connect(@nodes.volume)

    # store node
    @nodes.analyser = analyser_node



  #
  #  Analyse
  #
  analyse: () =>
    number_of_bars = 2
    points = 1024
    dimensions = []

    # frequency-domain data
    data = new Uint8Array(points)
    @nodes.analyser.getByteFrequencyData(data)

    # bin size
    bin_size = Math.floor(points / number_of_bars)

    # break it down
    for i in [0...number_of_bars]
      sum = 0

      for j in [0...bin_size]
        sum = sum + data[(i * bin_size) + j]

      # average
      average = sum / bin_size

      # calculate width
      width = (average / 256) * OngakuRyoho.VisualizationsView.peak_data_canvas.width

      # add to array
      dimensions.push(width)

    # visualize
    OngakuRyoho.VisualizationsView.visualize("peak_data", dimensions)

    # animation loop
    requestAnimationFrame(this.analyse)



  #
  #  Start analysing interval
  #
  start_analysing: () =>
    requestAnimationFrame(this.analyse)



  #
  #  Create audio elements container
  #
  create_audio_elements_container: () =>
    @cntnr = $("<div id=\"audio-elements\" />")
    @cntnr.appendTo($("body"))



  #
  #  Create new audio element
  #
  create_new_audio_element: (related_track, autoplay) =>
    audio_element = new window.Audio()
    audio_element.setAttribute("src", related_track.get("url"))
    audio_element.setAttribute("rel", related_track.id)

    # events, in order of the w3c spec
    audio_element.addEventListener("ended", this.events_finish)
    audio_element.addEventListener("durationchange", this.events_duration_change)
    audio_element.addEventListener("timeupdate", this.events_time_update)
    audio_element.addEventListener("canplay", () ->
      this.play() if autoplay
    )

    # add element to dom
    @cntnr.append(audio_element)

    # add to collection
    @audio_elements.push(audio_element)

    # return
    return audio_element



  #
  #  Create new source
  #
  create_new_source: (track, autoplay=false) =>
    track_id = track.get("id")

    # find existing audio element
    audio_element = _.find(@audio_elements, (audio_element) ->
      return audio_element.rel is track_id
    )

    # if no element exists yet
    audio_element ?= this.create_new_audio_element(track, autoplay)

    # create, connect and play
    setTimeout(() =>
      source = @ac.createMediaElementSource(audio_element)
      source.connect(@nodes.analyser)
      source.track = track

      @sources.push(source)
    , 0)



  #
  #  Active source?
  #
  get_active_source: () =>
    return _.last(@sources)



  #
  #  Destroy source
  #
  destroy_source: (source) =>
    source.mediaElement.pause()
    source.mediaElement.setAttribute("src", "")
    source.disconnect()

    # remove audio element from array
    @audio_elements.splice(@audio_elements.indexOf(source.mediaElement), 1)

    # remove audio element from DOM
    $(source.mediaElement).remove()

    # remove from sources array
    @sources.splice(@sources.indexOf(source), 1)



  #
  #  Destroy all sources
  #
  destroy_all_sources: () =>
    # make a copy of the sources array
    sources = @sources.slice(0)

    # destroy each
    _.each(sources, (source) => this.destroy_source(source))



  #
  #  Play source
  #
  play: (source) ->
    source.mediaElement.play()



  #
  #  Pause source
  #
  pause: (source) ->
    source.mediaElement.pause()



  #
  #  Fade out source
  #
  fade_out: (source) ->
    # remove from array first
    # then remove event handlers from audio element



  #
  #  Events / Loading
  #
  # events_load_start: () ->
  # events_load_end: () ->



  events_while_loading: (e) ->
    console.log("loading ...")



  # events_loaded_metadata: () ->
  # events_loaded_data: () ->



  #
  #  Events / Playing
  #
  # events_play: () ->
  # events_playing: () ->
  # events_can_play: () ->
  # events_can_play_through: () ->
  # events_pause: () ->
  events_finish: (e) =>
    repeat = OngakuRyoho.Controller.get("repeat")

    # action
    if repeat
      e.currentTarget.play()
    else
      @person.select_next_track()



  #
  #  Events / Errors, etc.
  #
  # events_load_suspend: () ->
  # events_load_abort: () ->
  # events_load_error: () ->
  # events_load_stalled: () ->
  # events_data_emptied: () ->



  #
  #  Events / Other
  #
  events_duration_change: (e) =>
    OngakuRyoho.Controller.set({ duration: e.currentTarget.duration })

  events_time_update: (e) =>
    OngakuRyoho.Controller.set({ time: e.currentTarget.currentTime })
