class OngakuRyoho.Classes.Machinery.MixingConsole

  #
  #  Set track info in document title
  #
  set_current_track_in_document_title: () ->
    Helpers.set_document_title("▶ #{@group.model.get("artist")} – #{@group.model.get("title")}")



  #
  #  Now playing marquee
  #
  setup_now_playing_marquee: ($now_playing) ->
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



  now_playing_marquee_animation: ($marquee_wrapper) ->
    text_width = $marquee_wrapper.children("span").first().width()
    anim_speed = text_width * 39.5

    # this machine
    _this = this

    # animation
    animation = () ->
      $marquee_wrapper.animate(
        { left: -text_width }, anim_speed, "linear",
        (e) ->
          $t = $(this)
          $t.css("left", 0)

          _this.now_playing_marquee_animation($t)
      )

    # animate
    _.delay(animation, 3000)



  #
  #  Now playing click handler
  #
  now_playing_click_handler: (e) ->
    OngakuRyoho.RecordBox.Tracks.machine.show_current_track()



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
    @group.model.toggle_attribute("shuffle")



  switch_repeat_click_handler: (e) =>
    @group.model.toggle_attribute("repeat")



  knob_volume_doubleclick_handler: (e) =>
    $t = $(e.currentTarget).find(".it div")

    # set volume
    @group.model.set("volume", 50)



  switch_volume_click_handler: (e) =>
    @group.model.toggle_attribute("mute")



  knob_low_doubleclick_handler: (e) =>
    @group.model.set("low_gain", 0)



  knob_mid_doubleclick_handler: (e) =>
    @group.model.set("mid_gain", 0)



  knob_hi_doubleclick_handler: (e) =>
    @group.model.set("hi_gain", 0)



  #
  #  Controller knobs
  #
  setup_knobs: ($knobs) ->
    that = this
    $knobs.each(() -> that.setup_knob($(this)))



  setup_knob: ($knob) ->
    $knob.on("mousedown", (e) ->
      $(document).on("mousemove", mouse_move)
                 .on("mouseup", mouse_up)
    )

    mouse_move = (e) =>
      angle = this.knob_get_angle($knob, e)
      item = _.without($knob.attr("class").split(" "), "knob")[0]
      biquad_filters = ["low", "mid", "hi"]
      funtion_arguments = []

      # mouse move event function & its arguments
      specific_mouse_move_event = if _.contains(biquad_filters, item)
        funtion_arguments.push(item, angle)
        this.knob_mouse_move_events.biquad_filter
      else
        funtion_arguments.push(angle)
        this.knob_mouse_move_events[item]

      # continue
      if specific_mouse_move_event
        specific_mouse_move_event.apply(this, funtion_arguments)
      else
        Helpers.css.rotate($knob.find(".it div"), angle)


    mouse_up = (e) ->
      $(document).off("mousemove", mouse_move)
                 .off("mouseup", mouse_up)



  knob_get_angle: ($knob, e) ->
    $t = $knob.find(".it div")
    knob_x = $t.offset().left + $t.width() / 2
    knob_y = $t.offset().top + $t.height() / 2
    mouse_x = e.pageX
    mouse_y = e.pageY

    mx = mouse_x - knob_x
    my = mouse_y - knob_y
    kx = 0
    ky = 0

    # calculate distance (from center of knob to e)
    distance = Math.sqrt(Math.pow(mx - kx, 2) + Math.pow(my - ky, 2))
    return if distance < 15

    # calculate angle
    angle = -(Math.atan2(kx - mx, ky - my) * (180 / Math.PI))

    # min and max
    if angle > 135 then angle = 135
    else if angle < -135 then angle = -135

    # return
    return angle



  knob_mouse_move_events:
    volume: (angle) ->
      volume = 50 + (angle / 135) * 50
      @group.model.set("volume", volume)



    biquad_filter: (type, angle) ->
      percent = Math.abs(angle) / 135

      gain = if angle < 0
        -(50 * percent)
      else
        percent * @group.model.get("#{type}_max_db")

      @group.model.set("#{type}_gain", gain)



  #
  #  Progress bar
  #
  progress_bar_click_handler: (e) ->
    $progress_bar = $(e.currentTarget).children(".progress-bar")

    # set
    percent = (e.pageX - $progress_bar.offset().left) / $progress_bar.width()

    # seek
    OngakuRyoho.People.SoundGuy.seek_current_track(percent)
