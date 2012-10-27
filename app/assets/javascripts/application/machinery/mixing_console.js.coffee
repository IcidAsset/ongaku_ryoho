class OngakuRyoho.Classes.Machinery.MixingConsole

  #
  #  Set track info in document title
  #
  set_current_track_in_document_title: () ->
    m = OngakuRyoho.MixingConsole.model
    Helpers.set_document_title("▶ #{m.get("artist")} – #{m.get("title")}")



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
    OngakuRyoho.Playlist.machine.show_current_track()



  #
  #  Controller buttons
  #
  button_playpause_click_handler: (e) ->
    OngakuRyoho.People.SoundGuy.toggle_playpause()



  button_previous_click_handler: (e) ->
    OngakuRyoho.People.SoundGuy.select_previous_track()



  button_next_click_handler: (e) ->
    OngakuRyoho.People.SoundGuy.select_next_track()



  switch_shuffle_click_handler: (e) =>
    m = OngakuRyoho.MixingConsole.model
    m.set("shuffle", !m.get("shuffle"))



  switch_repeat_click_handler: (e) =>
    m = OngakuRyoho.MixingConsole.model
    m.set("repeat", !m.get("repeat"))



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
    OngakuRyoho.MixingConsole.model.set("volume", volume)



  document_mouseup_handler_for_volume_knob: (e) =>
    # unbind
    $(document).off("mousemove", this.document_mousemove_handler_for_volume_knob)
    $(document).off("mouseup", this.document_mouseup_handler_for_volume_knob)

    # rebind
    OngakuRyoho.MixingConsole.view.$el
      .find(".controls .knob.volume")
      .on("mousedown", this.knob_volume_mousedown_handler)



  knob_volume_doubleclick_handler: (e) =>
    $t = $(e.currentTarget).find(".it div")

    # reset rotation
    Helpers.css.rotate($t, 0)

    # set volume
    OngakuRyoho.MixingConsole.model.set("volume", 50)



  switch_volume_click_handler: (e) =>
    m = OngakuRyoho.MixingConsole.model
    m.set("mute", !m.get("mute"))



  #
  #  Progress bar
  #
  progress_bar_click_handler: (e) ->
    $progress_bar = $(e.currentTarget).children(".progress-bar")

    # set
    percent = (e.pageX - $progress_bar.offset().left) / $progress_bar.width()

    # seek
    OngakuRyoho.People.SoundGuy.seek_current_track(percent)
