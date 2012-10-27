class OngakuRyoho.Classes.Views.MixingConsole extends Backbone.View

  time_template:         _.template("<%= time %>")
  now_playing_template:  _.template("<span><%= now_playing %></span>")



  #
  #  Events
  #
  events: () ->
    "click .now-playing"                              : @group.machine.now_playing_click_handler
    "click .progress-bar-wrapper"                     : @group.machine.progress_bar_click_handler

    "click .controls a .button.play-pause"            : @group.machine.button_playpause_click_handler
    "click .controls a .button-column .btn.previous"  : @group.machine.button_previous_click_handler
    "click .controls a .button-column .btn.next"      : @group.machine.button_next_click_handler
    "click .controls a .switch.shuffle"               : @group.machine.switch_shuffle_click_handler
    "click .controls a .switch.repeat"                : @group.machine.switch_repeat_click_handler
    "click .controls a .switch.volume"                : @group.machine.switch_volume_click_handler

    "dblclick .controls a .knob.volume"               : @group.machine.knob_volume_doubleclick_handler



  #
  #  Initialize
  #
  initialize: () =>
    super()

    # render events
    @group.model
      .on("change:time", this.render_time)
      .on("change:now_playing", this.render_now_playing)

    # sound events
    @group.model
      .on("change:shuffle", OngakuRyoho.People.SoundGuy.set_shuffle)
      .on("change:repeat", OngakuRyoho.People.SoundGuy.set_repeat)
      .on("change:volume", OngakuRyoho.People.SoundGuy.set_volume)
      .on("change:mute", OngakuRyoho.People.SoundGuy.set_mute)

    # cache dom elements
    this.$now_playing  = this.$el.find(".now-playing")
    this.$progress_bar = this.$el.find(".progress-bar")
    this.$controls = this.$el.find(".controls")

    # render
    this.render_time()
    this.render_now_playing()

    # more events
    this.$control("knob", "volume")
        .on("mousedown", @group.machine.knob_volume_mousedown_handler)



  #
  #  Grab $control
  #
  $control: (type, klass, extra="") =>
    return this.$controls.find("a .#{type}.#{klass} #{extra}")



  #
  #  Render
  #
  render_time: () =>
    time     = @group.model.get("time")
    duration = @group.model.get("duration")

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
      @now_playing_template({ now_playing: @group.model.get("now_playing") })
    )

    # activate animation
    @group.machine.setup_now_playing_marquee(this.$now_playing)

    # chain
    return this
