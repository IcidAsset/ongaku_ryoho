class OngakuRyoho.Classes.Machinery.Controller

  #
  #  Set track info in document title
  #
  set_current_track_in_document_title: () =>
    Helpers.set_document_title("▶ #{@view.model.get("artist")} – #{@view.model.get("title")}")



  #
  #  Now playing marquee
  #
  setup_now_playing_marquee: ($now_playing) =>
    $item = $now_playing.children(".item")
    $span = $item.children("span")

    # widths
    item_width = $item.width()
    text_width = $span.width()

    # check
    return if text_width < item_width

    # item css
    $item
      .css({ position: "relative" })

    # item span css
    $span
      .wrap("<div class=\"marquee-wrapper\"></div>")
      .css({ float: "left", paddingRight: "65px" })
      .parent()
      .css({
        overflow: "hidden",
        position: "absolute",
        width: "5000px"
      })

    # clone span
    $span.after($span.clone())

    # animate with marquee-wrapper
    this.now_playing_marquee_animation($span.parent())



  now_playing_marquee_animation: ($marquee_wrapper) =>
    text_width = $marquee_wrapper.children("span").first().width()
    anim_speed = text_width * 39.5

    # this machine
    mc = this

    # animation
    animation = () ->
      $marquee_wrapper.animate(
        { left: -text_width }, anim_speed, "linear",
        (e) ->
          $t = $(this)
          $t.css("left", 0)

          mc.now_playing_marquee_animation($t)
      )

    # animate
    _.delay(animation, 3000)



  #
  #  Now playing click handler
  #
  now_playing_click_handler: (e) ->
    OngakuRyoho.PlaylistView.machine.show_current_track()



  #
  #  Controller buttons
  #
  button_playpause_click_handler: (e) ->
    $button = $(e.currentTarget)

    # source
    source = OngakuRyoho.SoundGuy.machine.get_active_source()

    # state
    state = if source and !source.mediaElement.paused
      "playing"
    else
      "not playing"

    # action
    if state is "playing"
      OngakuRyoho.SoundGuy.pause_current_track()
    else
      OngakuRyoho.SoundGuy.play_track()

    # light
    if state is "playing"
      $button.children(".light").removeClass("on")
    else
      $button.children(".light").addClass("on")



  switch_shuffle_click_handler: (e) =>
    @view.model.set("shuffle", !@view.model.get("shuffle"))



  switch_repeat_click_handler: (e) =>
    @view.model.set("repeat", !@view.model.get("repeat"))



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
    @view.model.set("volume", volume)



  document_mouseup_handler_for_volume_knob: (e) =>
    # unbind
    $(document).off("mousemove", this.document_mousemove_handler_for_volume_knob)
    $(document).off("mouseup", this.document_mouseup_handler_for_volume_knob)

    # rebind
    @view.$el.find(".controls .knob.volume")
         .on("mousedown", this.knob_volume_mousedown_handler)



  knob_volume_doubleclick_handler: (e) =>
    $t = $(e.currentTarget).find(".it div")

    # reset rotation
    Helpers.css.rotate($t, 0)

    # set volume
    @view.model.set("volume", 50)



  switch_volume_click_handler: (e) =>
    @view.model.set("mute", !@view.model.get("mute"))



  #
  #  Progress bar
  #
  progress_bar_click_handler: (e) ->
    $progress_bar = $(e.currentTarget).children(".progress-bar")

    # set
    percent = (e.pageX - $progress_bar.offset().left) / $progress_bar.width()

    # source
    source = OngakuRyoho.SoundGuy.machine.get_active_source()

    # check
    return unless source

    # seek
    source.mediaElement.currentTime = source.mediaElement.duration * percent
