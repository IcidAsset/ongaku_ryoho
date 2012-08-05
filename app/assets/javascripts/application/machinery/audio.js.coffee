class OngakuRyoho.Classes.Machinery.Audio

  setup: () =>
    @current_source = null
    @audio_elements = []
    @nodes = {}
    @events = {}

    this.set_audio_context()
    this.create_audio_elements_container()
    this.create_volume_node()



  #
  #  Set audio context
  #
  set_audio_context: () =>
    if typeof AudioContext is "function"
      @ac = new AudioContext()
    else if typeof webkitAudioContext is "function"
      @ac = new webkitAudioContext()
    else
      console.error("Web Audio API not supported!")



  #
  #  Create audio elements container
  #
  create_audio_elements_container: () =>
    @cntnr = $("<div id=\"audio-elements\" />")
    @cntnr.appendTo($("body"))



  #
  #  Create volume node
  #
  create_volume_node: () =>
    volume_node = @ac.createGainNode()
    volume_node.gain.value = 0.5

    # connect to destination
    volume_node.connect(@ac.destination)

    # store node
    @nodes.volume = volume_node



  #
  #  Create new audio element
  #
  create_new_audio_element: (related_track) =>
    audio_element = new window.Audio()
    audio_element.src = related_track.get("url")
    audio_element.rel = related_track.id
    audio_element.preload = "auto"

    # events, in order of the w3c spec
    audio_element.addEventListener("loadstart", this.load_start)
    audio_element.addEventListener("progress", this.while_loading)
    audio_element.addEventListener("canplay", this.can_play)

    # add element to dom
    @cntnr.append(audio_element)

    # add to collection
    @audio_elements.push(audio_element)

    # return
    return audio_element



  #
  #  Play
  #
  play: (track) =>
    track_id = track.get("id")

    # find existing audio element
    audio_element = _.find(@audio_elements, (audio_element) ->
      return audio_element.rel is track_id
    )

    # if no element exists yet
    audio_element = this.create_new_audio_element(track)

    # create source
    source = @ac.createMediaElementSource(audio_element)

    # connect to volume node
    source.connect(@nodes.volume)

    return source



  #
  #  Events / Loading
  #
  events_load_start: () ->
    console.log("load start")



  events_load_end: () ->



  events_while_loading: () ->
    console.log("loading ...")



  events_loaded_metadata: () ->



  events_loaded_data: () ->



  #
  #  Events / Playing
  #
  events_play: () ->



  events_playing: () ->



  events_can_play: () ->
    console.info("can play")



  events_can_play_through: () ->



  events_pause: () ->



  events_finish: () ->



  #
  #  Events / Errors, etc.
  #
  events_load_suspend: () ->



  events_load_abort: () ->



  events_load_error: () ->



  events_load_stalled: () ->



  events_data_emptied: () ->



  #
  #  Events / Other
  #
  events_duration_change: () ->
