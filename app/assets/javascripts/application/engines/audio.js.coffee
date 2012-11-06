class OngakuRyoho.Classes.Engines.Audio

  setup: () ->
    @sources = []
    @audio_elements = []
    @nodes = {}
    @req_anim_frame_id = null

    this.set_audio_context()
    this.create_volume_node()
    this.create_analyser_nodes()
    this.create_channel_splitter_node()
    this.create_audio_elements_container()



  #
  #  Set audio context
  #
  set_audio_context: () ->
    unless typeof AudioContext is "undefined"
      @ac = new AudioContext()
    else unless typeof webkitAudioContext is "undefined"
      @ac = new webkitAudioContext()
    else
      console.error("Web Audio API not supported!")



  #
  #  Create volume node
  #
  create_volume_node: () ->
    volume_node = @ac.createGainNode()
    volume_node.gain.value = 1

    # connect to destination
    volume_node.connect(@ac.destination)

    # store node
    @nodes.volume = volume_node



  #
  #  Set volume
  #
  set_volume: (value) ->
    @nodes.volume.gain.value = value



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
      width = (average / 256) * OngakuRyoho.Visualizations.view.peak_data_context.canvas.width

      # add to array
      dimensions.push(width)

    # visualize
    OngakuRyoho.Visualizations.view.visualize("peak_data", dimensions)



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
    audio_element.setAttribute("src", related_track.get("url"))
    audio_element.setAttribute("rel", related_track.id)

    # events, in order of the w3c spec
    audio_element.addEventListener("progress", this.events.progress)
    audio_element.addEventListener("suspend", this.events.suspend)
    audio_element.addEventListener("timeupdate", this.events.time_update)
    audio_element.addEventListener("ended", this.events.ended)
    audio_element.addEventListener("durationchange", this.events.duration_change)
    audio_element.addEventListener("canplay", (e) =>
      e.target.play() if autoplay
      this.start_analysing() if autoplay
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

    # find existing audio element
    audio_element = _.find(@audio_elements, (audio_element) ->
      return audio_element.rel is track_id
    )

    # if no element exists yet
    audio_element ?= this.create_new_audio_element(track, autoplay)

    # create, connect and play
    setTimeout(() =>
      source = @ac.createMediaElementSource(audio_element)
      source.connect(@nodes.channel_splitter)
      source.connect(@nodes.volume)
      source.track = track

      @sources.push(source)

      # fill up queue
      OngakuRyoho.Engines.Queue.set_next()
    , 0)



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
  destroy_all_sources: () ->
    # make a copy of the sources array
    sources = @sources.slice(0)

    # destroy each
    _.each(sources, (source) => this.destroy_source(source))



  #
  #  Play source
  #
  play: (source) ->
    source.mediaElement.play()
    this.start_analysing()



  #
  #  Pause source
  #
  pause: (source) ->
    source.mediaElement.pause()
    this.stop_analysing()



  #
  #  Is source paused?
  #
  is_paused: (source) ->
    return source.mediaElement.paused



  #
  #  Seek
  #
  seek: (source, percent) ->
    source.mediaElement.currentTime = source.mediaElement.duration * percent



  #
  #  Fade out source
  #
  fade_out: (source) ->
    # remove from array first
    # then remove event handlers from audio element



  #
  #  Events
  #
  events:

    progress: (e) ->
      buffered = e.target.buffered
      return unless buffered.length

      percent_loaded = ((buffered.end(0) / e.target.duration) * 100) + "%"

      OngakuRyoho.MixingConsole.view.$progress_bar
        .children(".progress.loader")
        .css("width", percent_loaded)



    suspend: (e) ->
      # console.log("suspend")



    time_update: (e) =>
      OngakuRyoho.MixingConsole.model.set({ time: e.target.currentTime })



    ended: (e) =>
      repeat = OngakuRyoho.MixingConsole.model.get("repeat")

      # action
      if repeat
        e.target.play()
      else
        OngakuRyoho.People.SoundGuy.select_next_track()



    duration_change: (e) =>
      OngakuRyoho.MixingConsole.model.set({ duration: e.target.duration })
