class OngakuRyoho.Classes.Views.Controller extends Backbone.View

  time_template:         _.template("<%= time %>")
  now_playing_template:  _.template("<span><%= now_playing %></span>")



  #
  #  Initialize
  #
  initialize: () =>
    @model = 颪.Controller
    @machine = OngakuRyoho.Machinery.Controller

    # render events
    @model
      .on("change:time", this.render_time)
      .on("change:now_playing", this.render_now_playing)

    # sound events
    @model
      .on("change:shuffle", 颪.SoundGuy.set_shuffle)
      .on("change:repeat", 颪.SoundGuy.set_repeat)
      .on("change:volume", 颪.SoundGuy.set_volume)
      .on("change:mute", 颪.SoundGuy.set_mute)

    # cache dom elements
    this.$now_playing  = this.$el.find(".now-playing")
    this.$progress_bar = this.$el.find(".progress-bar")
    this.$controls     = this.$el.children(".controls")

    # render
    this.render_time()
    this.render_now_playing()

    # setup machine
    @machine.setup(this.$el)
    @machine.setup_controller_buttons(this.$controls)
    @machine.setup_progress_bar(this.$progress_bar)



  #
  #  Set track info in document title
  #
  set_current_track_in_document_title: () =>
    Helpers.set_document_title("▶ #{@model.get("artist")} – #{@model.get("title")}")



  #
  #  Render
  #
  render_time: () =>
    time     = @model.get("time")
    duration = @model.get("duration")

    # duration? really?
    if (!duration or duration is 0) and 颪.SoundGuy.current_sound
      duration = 颪.SoundGuy.current_sound.durationEstimate

    # set
    minutes = Math.floor( (time / 1000) / 60 )
    seconds = Math.floor( (time / 1000) - (minutes * 60) )

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
