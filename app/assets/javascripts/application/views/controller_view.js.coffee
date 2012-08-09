class OngakuRyoho.Classes.Views.Controller extends Backbone.View

  time_template:         _.template("<%= time %>")
  now_playing_template:  _.template("<span><%= now_playing %></span>")



  #
  #  Events
  #
  events: () ->
    "click .now-playing"                              : @machine.now_playing_click_handler
    "click .progress-bar-wrapper"                     : @machine.progress_bar_click_handler

    "click .controls a .button.play-pause"            : @machine.button_playpause_click_handler
    "click .controls a .button-column .btn.previous"  : OngakuRyoho.SoundGuy.select_previous_track
    "click .controls a .button-column .btn.next"      : OngakuRyoho.SoundGuy.select_next_track
    "click .controls a .switch.shuffle"               : @machine.switch_shuffle_click_handler
    "click .controls a .switch.repeat"                : @machine.switch_repeat_click_handler
    "click .controls a .switch.volume"                : @machine.switch_volume_click_handler

    "dblclick .controls a .knob.volume"               : @machine.knob_volume_doubleclick_handler



  #
  #  Initialize
  #
  initialize: () =>
    super()

    # model
    @model = OngakuRyoho.Controller

    # render events
    @model
      .on("change:time", this.render_time)
      .on("change:now_playing", this.render_now_playing)

    # sound events
    @model
      .on("change:shuffle", OngakuRyoho.SoundGuy.set_shuffle)
      .on("change:repeat", OngakuRyoho.SoundGuy.set_repeat)
      .on("change:volume", OngakuRyoho.SoundGuy.set_volume)
      .on("change:mute", OngakuRyoho.SoundGuy.set_mute)

    # cache dom elements
    this.$now_playing  = this.$el.find(".now-playing")
    this.$progress_bar = this.$el.find(".progress-bar")
    this.$controls = this.$el.find(".controls")

    # render
    this.render_time()
    this.render_now_playing()

    # more events
    this.$control("knob", "volume")
        .on("mousedown", @machine.knob_volume_mousedown_handler)



  #
  #  Grab $control
  #
  $control: (type, klass, extra="") =>
    return this.$controls.find("a .#{type}.#{klass} #{extra}")



  #
  #  Render
  #
  render_time: () =>
    time     = @model.get("time")
    duration = @model.get("duration")

    # set
    minutes = Math.floor(time / 60)
    seconds = Math.floor(time - (minutes * 60) )

    progress = (time / duration) * 100

    # prepare
    minutes = "0#{minutes}" if minutes.toString().length is 1
    seconds = "0#{seconds}" if seconds.toString().length is 1

    # time
    this.$now_playing.children(".time").html(
      @time_template({ time: "#{minutes}:#{seconds}" })
    )

    # progress bar
    this.$progress_bar
      .children(".progress.track")
      .css("width", "#{progress}%")

    # chain
    return this



  render_now_playing: () =>
    # set content
    this.$now_playing.children(".item").html(
      @now_playing_template({ now_playing: @model.get("now_playing") })
    )

    # activate animation
    @machine.setup_now_playing_marquee(this.$now_playing)

    # chain
    return this
