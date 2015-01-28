class OngakuRyoho.Classes.Engines.Audio

  constructor: () ->
    @sources = []
    @audio_elements = []
    @nodes = {}
    @req_anim_frame_id = null



  setup: () ->
    this.has_been_setup = true
    this.set_audio_context()

    this.create_analyser_nodes()
    this.create_channel_splitter_node()
    this.create_biquad_filters()
    this.create_volume_node()

    this.create_audio_elements_container()



  #
  #  Flags
  #
  has_been_setup: false



  #
  #  Set audio context
  #
  set_audio_context: () ->
    unless typeof AudioContext is "undefined"
      @ac = new AudioContext()
      @ac_type = "standard"
    else unless typeof webkitAudioContext is "undefined"
      @ac = new webkitAudioContext()
      @ac_type = "webkit"
    else
      console.error("Web Audio API not supported!")



  #
  #  Create volume node
  #
  create_volume_node: () ->
    volume_node = if @ac_type is "webkit"
      @ac.createGainNode()
    else
      @ac.createGain()

    volume_node.gain.value = 1

    # connect to destination
    volume_node.connect(@nodes.biquad.low)

    # store node
    @nodes.volume = volume_node



  #
  #  Set volume
  #
  set_volume: (value) ->
    unless _.isNaN(value)
      @nodes.volume.gain.value = value



  #
  #  Create biquad filters
  #
  create_biquad_filters: () ->
    low = @ac.createBiquadFilter()
    mid = @ac.createBiquadFilter()
    hi = @ac.createBiquadFilter()

    if @ac_type is "webkit"
      low.type = 3
      mid.type = 5
      hi.type = 4
    else
      low.type = "lowshelf"
      mid.type = "peaking"
      hi.type = "highshelf"

    low.frequency.value = OngakuRyoho.MixingConsole.model.get("low_frequency")
    mid.frequency.value = OngakuRyoho.MixingConsole.model.get("mid_frequency")
    hi.frequency.value = OngakuRyoho.MixingConsole.model.get("hi_frequency")

    mid.Q.value = 1

    low.connect(mid)
    mid.connect(hi)
    hi.connect(@ac.destination)

    if this.should_analyse()
      hi.connect(@nodes.channel_splitter)

    @nodes.biquad =
      low: low
      mid: mid
      hi: hi



  #
  #  Set biquad filter gain
  #
  set_biquad_filter_gain: (shelf, gain) ->
    @nodes.biquad[shelf].gain.value = gain



  #
  #  Create analyser nodes
  #
  create_analyser_nodes: () ->
    analyser_node_left = @ac.createAnalyser()
    analyser_node_right = @ac.createAnalyser()
    analyser_node_left.fftSize = 256
    analyser_node_right.fftSize = 256

    # store nodes
    @nodes.analyser_left = analyser_node_left
    @nodes.analyser_right = analyser_node_right



  #
  #  Analyse
  #
  analyse: () =>
    @req_anim_frame_id = requestAnimationFrame(this.analyse)

    # set
    canvas_width = parseInt(OngakuRyoho.Visualizations.view.peak_data_context.canvas.width, 10)
    points_left = @nodes.analyser_left.frequencyBinCount
    points_right = @nodes.analyser_right.frequencyBinCount
    points = [points_left, points_right]

    dimensions = []

    # frequency-domain data
    data_left = new Uint8Array(points_left)
    data_right = new Uint8Array(points_right)

    @nodes.analyser_left.getByteFrequencyData(data_left)
    @nodes.analyser_right.getByteFrequencyData(data_right)

    # break it down
    for data, idx in [data_left, data_right]
      sum = 0

      # sum
      sum = sum + data[j] for j in [0...points[idx]]

      # average
      average = sum / points[idx]

      # calculate width
      width = (average / 256) * canvas_width

      # add to array
      dimensions.push(width)

    # visualize
    OngakuRyoho.Visualizations.view.visualize("peak_data", dimensions)

    # nullify
    points = null
    data_left = null
    data_right = null
    dimensions = null



  should_analyse: () ->
    if OngakuRyohoPreloadedData.user.settings.disable_visualizations is "1"
      false
    else if $.os.tablet or $.os.phone
      false
    else if $.browser.safari
      false
    else
      true



  #
  #  Start/stop analysing interval
  #
  start_analysing: () ->
    this.analyse() if @req_anim_frame_id is null



  stop_analysing: () ->
    cancelAnimationFrame(@req_anim_frame_id)
    @req_anim_frame_id = null



  #
  #  Create channel splitter node
  #
  create_channel_splitter_node: () ->
    channel_splitter_node = @ac.createChannelSplitter(2)

    # connect to analyser
    channel_splitter_node.connect(@nodes.analyser_left, 0, 0)
    channel_splitter_node.connect(@nodes.analyser_right, 1, 0)

    # store node
    @nodes.channel_splitter = channel_splitter_node



  #
  #  Create audio elements container
  #
  create_audio_elements_container: () ->
    @cntnr = $("<div id=\"audio-elements\" />")
    @cntnr.appendTo($("body"))



  #
  #  Create new audio element
  #
  create_new_audio_element: (related_track, autoplay) ->
    audio_element = new window.Audio()

    # check audio support
    mimetype = MimeType.lookup(related_track.get("filename"))
    return false if !mimetype or audio_element.canPlayType(mimetype) is ""

    # encode uri
    url = related_track.get("url")
    source = OngakuRyoho.SourceManager.collection.get(related_track.get("source_id"))
    src = source.type_instance.track_url_to_src(url, related_track.get("location"))

    # track
    audio_element.setAttribute("src", src)
    audio_element.setAttribute("rel", related_track.id)

    # events, in order of the w3c spec
    audio_element.addEventListener("progress", this.events.progress)
    audio_element.addEventListener("error", this.events.error)
    audio_element.addEventListener("timeupdate", this.events.time_update)
    audio_element.addEventListener("ended", this.events.ended)
    audio_element.addEventListener("durationchange", this.events.duration_change)

    # load
    audio_element.load()

    # play
    if $.os.tablet or $.os.phone
      if autoplay
        audio_element.play()
    else
      audio_element.addEventListener("canplay", (e) =>
        if autoplay
          e.target.play()
          this.start_analysing() if this.should_analyse()
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
  create_new_source: (track, autoplay=false) ->
    track_id = track.get("id")
    promise = new RSVP.Promise()

    # find existing audio element
    audio_element = _.find(@audio_elements, (audio_element) ->
      return audio_element.rel is track_id
    )

    # if no element exists yet
    audio_element ?= this.create_new_audio_element(track, autoplay)

    # check audio support
    return null unless audio_element

    # audio element volume
    audio_element.volume = 1

    # create, connect and play
    setTimeout(() =>
      source = @ac.createMediaElementSource(audio_element)
      source.mediaElement = audio_element unless source.mediaElement
      source.connect(@nodes.volume)
      source.track = track
      source.id = track.cid

      @sources.push(source)
    , 0)

    # wait until first timeupdate
    $(audio_element).one("timeupdate", -> promise.resolve())

    # return
    return promise



  #
  #  Active source?
  #
  get_active_source: () ->
    return _.last(@sources)



  #
  #  Destroy source
  #
  destroy_source: (source) ->
    source.mediaElement.pause()

    # remove all event listeners
    source.mediaElement.removeEventListener("progress", this.events.progress)
    source.mediaElement.removeEventListener("error", this.events.error)
    source.mediaElement.removeEventListener("timeupdate", this.events.time_update)
    source.mediaElement.removeEventListener("ended", this.events.ended)
    source.mediaElement.removeEventListener("durationchange", this.events.duration_change)
    source.mediaElement.removeEventListener("canplay")

    # disconnect
    source.mediaElement.setAttribute("src", "")
    source.disconnect()

    # remove audio element from array
    @audio_elements.splice(@audio_elements.indexOf(source.mediaElement), 1)

    # remove audio element from DOM
    $(source.mediaElement).remove()

    # nullify (ensure gc)
    source.track = null
    source = null



  #
  #  Destroy all sources
  #
  destroy_all_sources: (exceptions) ->
    exception_ids = _.map(exceptions || [], (e) -> e.id)
    sources_to_remove = []

    # sort sources
    @sources = _.compact(_.map(@sources, (source) ->
      if _.contains(exception_ids, source.id)
        source
      else
        sources_to_remove.push(source)
        null
    ))

    # destroy each
    _.each(sources_to_remove, (source) =>
      this.destroy_source(source)
    )



  #
  #  Play source
  #
  play: (source) ->
    source.mediaElement.play()
    this.start_analysing() if this.should_analyse()



  #
  #  Pause source
  #
  pause: (source) ->
    source.mediaElement.pause()
    this.stop_analysing() if this.should_analyse()



  #
  #  Is source paused?
  #
  is_paused: (source) ->
    return source.mediaElement.paused



  #
  #  Seek
  #
  seek: (source, percent) ->
    unless _.isNaN(source.mediaElement.duration)
      source.mediaElement.currentTime = source.mediaElement.duration * percent



  #
  #  Events
  #
  events:

    progress: (e) ->
      return unless e.target.buffered.length
      percent_loaded = ((e.target.buffered.end(0) / e.target.duration) * 100) + "%"

      OngakuRyoho.MixingConsole.view.el_progress_bar
        .querySelector(".progress.loader")
        .style.width = percent_loaded



    error: (e) ->
      console.error("Audio engine error")



    time_update: (e) =>
      OngakuRyoho.MixingConsole.view.render_time(e.target.currentTime)



    ended: (e) =>
      repeat = OngakuRyoho.MixingConsole.model.get("repeat")

      # action
      if repeat
        e.target.play()
      else
        OngakuRyoho.People.SoundGuy.select_next_track()



    duration_change: (e) =>
      OngakuRyoho.MixingConsole.model.set("duration", e.target.duration)
