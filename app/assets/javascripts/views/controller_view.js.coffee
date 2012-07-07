class OngakuRyoho.Views.Controller extends Backbone.View
  
  time_template:         _.template("<%= time %>")
  now_playing_template:  _.template("<span><%= now_playing %></span>")


  #
  #  Events
  #
  events:
    "click .now-playing" : "now_playing_click_handler"



  #
  #  Initialize
  #
  initialize: () =>
    @model = window.Controller
    @model.on("change:time", this.render_time)
    @model.on("change:now_playing", this.render_now_playing)
    @model.on("change:shuffle", SoundGuy.set_shuffle)
    @model.on("change:repeat", SoundGuy.set_repeat)
    @model.on("change:volume", SoundGuy.set_volume)
    @model.on("change:mute", SoundGuy.set_mute)

    this.$now_playing  = this.$el.find(".now-playing")
    this.$progress_bar = this.$el.find(".progress-bar")

    this.render_time()
    this.render_now_playing()
    
    this.setup_controller_buttons()
    this.setup_progress_bar()
  
  
  
  #
  #  Set track info in document title
  #
  set_current_track_in_document_title: () =>
    helpers.set_document_title("▶ #{@model.get("artist")} – #{@model.get("title")}")
  
  
  
  #
  #  Render
  #
  render_time: () =>
    time       = @model.get("time")
    duration   = @model.get("duration")
    
    # duration? really?
    if (!duration or duration is 0) and SoundGuy.current_sound
      duration = SoundGuy.current_sound.durationEstimate
    
    # set
    minutes    = Math.floor( (time / 1000) / 60 )
    seconds    = Math.floor( (time / 1000) - (minutes * 60) )
    
    progress   = (time / duration) * 100
    
    # prepare
    minutes = "0#{minutes}" if minutes.toString().length is 1
    seconds = "0#{seconds}" if seconds.toString().length is 1
    
    # time
    this.$now_playing.children(".time").html(
      this.time_template({ time: "#{minutes}:#{seconds}" })
    )
    
    # progress bar
    this.$progress_bar
      .children(".progress.track")
      .css("width", "#{progress}%")
    
    # chain
    return this
  
  
  
  render_now_playing: () =>
    # set content
    this.$now_playing.children(".what").html(
      this.now_playing_template({ now_playing: @model.get("now_playing") })
    )
    
    # activate animation
    this.now_playing_marquee()
    
    # chain
    return this
  
  
  
  #
  #  Controller buttons
  #
  setup_controller_buttons: () =>
    $controls        = this.$el.children(".controls")
    $buttons         = $controls.find("a .button")
    $button_columns  = $controls.find("a .button-column")
    $switches        = $controls.find("a .switch")
    $knobs           = $controls.find("a .knob")
    
    # play/pause button
    $buttons.filter(".play-pause").on("click", this.button_playpause_click_handler)
    
    # previous and next
    $button_columns
      .children(".btn.previous")
      .on("click", SoundGuy.select_previous_track)
    
    $button_columns
      .children(".btn.next")
      .on("click", SoundGuy.select_next_track)
    
    # shuffle
    $switches.filter(".shuffle").on("click", this.switch_shuffle_click_handler)
    
    # repeat
    $switches.filter(".repeat").on("click", this.switch_repeat_click_handler)
    
    # volume
    $knobs.filter(".volume")
      .on("mousedown", this.knob_volume_mousedown_handler)
      .on("dblclick", this.knob_volume_doubleclick_handler)
    
    $switches.filter(".volume").on("click", this.switch_volume_click_handler)
  
  
  
  button_playpause_click_handler: (e) =>
    return unless soundManager.ok()
    
    # set
    $button = $(e.currentTarget)
    state = if SoundGuy.current_sound and !SoundGuy.current_sound.paused
      "playing"
    else
      "not playing"
    
    # action
    if state is "playing"
      SoundGuy.pause_current_track()
    else
      SoundGuy.play_track()
    
    # light
    if state is "playing"
      $button.children(".light").removeClass("on")
    else
      $button.children(".light").addClass("on")
  
  
  
  switch_shuffle_click_handler: (e) =>
    @model.set("shuffle", !@model.get("shuffle"))
  
  
  
  switch_repeat_click_handler: (e) =>
    @model.set("repeat", !@model.get("repeat"))
  
  
  
  knob_volume_mousedown_handler: (e) =>
    $(e.currentTarget).off("mousedown", this.knob_volume_mousedown_handler)
    $(document).on("mousemove", this.document_mousemove_handler_for_volume_knob)
    $(document).on("mouseup", this.document_mouseup_handler_for_volume_knob)
  
  
  
  document_mousemove_handler_for_volume_knob: (e) =>
    $t = $(e.currentTarget).find(".it div")
    knob_x = $t.offset().left + $t.width() / 2
    knob_y = $t.offset().top + $t.height() / 2
    mouse_x = e.pageX
    mouse_y = e.pageY
    
    mx = mouse_x - knob_x
    my = mouse_y - knob_y
    kx = 0
    ky = 0
    
    distance = Math.sqrt( Math.pow(mx - kx, 2) + Math.pow(my - ky, 2) )
    return if distance < 15
    
    angle = -(Math.atan2( kx - mx, ky - my ) * ( 180 / Math.PI ))
    
    if angle > 135 then angle = 135
    else if angle < -135 then angle = -135
    
    # set volume
    volume = 50 + (angle / 135) * 50
    @model.set("volume", volume)
  
  
  
  document_mouseup_handler_for_volume_knob: (e) =>
    # unbind
    $(document).off("mousemove", this.document_mousemove_handler_for_volume_knob)
    $(document).off("mouseup", this.document_mouseup_handler_for_volume_knob)
    
    # rebind
    this.$el
      .find(".controls .knob.volume")
      .on("mousedown", this.knob_volume_mousedown_handler)
  
  
  
  knob_volume_doubleclick_handler: (e) =>
    $t = $(e.currentTarget).find(".it div")
    
    # reset rotation
    helpers.css.rotate($t, 0)
    
    # set volume
    @model.set("volume", 50)
  
  
  
  switch_volume_click_handler: (e) =>
    @model.set("mute", !@model.get("mute"))
  
  
  
  #
  #  Setup progress bar
  #
  setup_progress_bar: () =>
    # mouse events
    this.$progress_bar.parent().on("click", this.progress_bar_click_handler)
  
  
  
  progress_bar_click_handler: (e) =>
    return unless SoundGuy.current_sound
    
    # set
    percent = (e.pageX - this.$progress_bar.offset().left) / this.$progress_bar.width()
    
    # seek
    SoundGuy.current_sound.setPosition( SoundGuy.current_sound.duration * percent )
  
  
  
  #
  #  Now playing marquee
  #
  now_playing_marquee: () =>
    $what = this.$el.find(".now-playing .what")
    $span = $what.children("span")
    wrap_width = $what.width()
    text_width = $span.width()
    
    # check
    return if text_width < wrap_width
    
    # css stuff
    $what.css({ position: "relative" })
    $span
      .wrap("<div class=\"marquee-wrapper\"></div>")
      .css({ float: "left", paddingRight: "65px" })
      .parent()
      .css({
        overflow: "hidden",
        position: "absolute",
        width: "5000px"
      })
    
    $span.after($span.clone())
    
    # animate
    this.now_playing_marquee_animation($span.parent())
  
  
  
  now_playing_marquee_animation: ($thing_that_scrolls) =>
    # width of text, etc.
    text_width = $thing_that_scrolls.children("span").first().width()
    anim_speed = text_width * 39.5
    wait_for   = 3000
    
    controller_view = this
    
    # animate
    _.delay(() ->
      $thing_that_scrolls.animate(
        { left: -text_width }, anim_speed, "linear",
        (e) ->
          $t = $(this)
          $t.css("left", 0)
          
          controller_view.now_playing_marquee_animation($t)
      )
    , wait_for)



  now_playing_click_handler: (e) ->
    PlaylistView.show_current_track()
