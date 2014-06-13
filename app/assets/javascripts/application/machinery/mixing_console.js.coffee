class OngakuRyoho.Classes.Machinery.MixingConsole

  constructor: () ->
    @npm_timeout_ids = []



  #
  #  Set track info in document title
  #
  set_current_track_in_document_title: () ->
    Helpers.set_document_title("▶ #{@group.model.get("artist")} – #{@group.model.get("title")}")



  #
  #  Now playing marquee
  #
  setup_now_playing_marquee: (now_playing) ->
    item = now_playing.querySelector(".item")
    span = item.querySelector("span")

    # check
    return unless item

    # clear existing timeouts
    this.clear_now_playing_marquee_timeouts()

    # widths
    item_width = item.offsetWidth
    text_width = span.offsetWidth

    # check
    return if text_width < item_width

    # item css
    item.style.position = "relative"

    # item span css
    item.innerHTML = """
      <div class="marquee-wrapper">
        <span style="float:left;padding-right:65px;">#{span.innerHTML}</span>
        <span style="float:left;padding-right:65px;">#{span.innerHTML}</span>
      </div>
    """

    spans = item.querySelectorAll("span")
    marquee_wrapper = spans[0].parentNode

    # continue
    if marquee_wrapper
      marquee_wrapper.style.cssText = "left:0px;overflow:hidden;position:absolute;width:5000px;"
      @npm_timeout_ids.push setTimeout(this.now_playing_marquee_animation, 3000)



  now_playing_marquee_animation: () =>
    marquee_wrapper = @group.view.el_now_playing.querySelector(".marquee-wrapper")
    text_width = marquee_wrapper.querySelector("span").offsetWidth
    anim_speed = text_width * 39.5

    $(marquee_wrapper).animate(
      { left: -text_width }, anim_speed, "linear",
      this.now_playing_marquee_animation_callback
    )



  now_playing_marquee_animation_callback: () =>
    marquee_wrapper = @group.view.el_now_playing.querySelector(".marquee-wrapper")
    marquee_wrapper.style.left = 0 if marquee_wrapper

    @npm_timeout_ids.push setTimeout(this.now_playing_marquee_animation, 3000)



  clear_now_playing_marquee_timeouts: () ->
    array_clone = @npm_timeout_ids.splice(0, @npm_timeout_ids.length)

    _.each(array_clone, (timeout_id) ->
      clearTimeout(timeout_id)
    )



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
    @group.model.set("volume", 50)



  switch_volume_click_handler: (e) =>
    @group.model.toggle_attribute("mute")



  knob_low_doubleclick_handler: (e) =>
    @group.model.set("low_gain", 0)



  knob_mid_doubleclick_handler: (e) =>
    @group.model.set("mid_gain", 0)



  knob_hi_doubleclick_handler: (e) =>
    @group.model.set("hi_gain", 0)



  knob_double_tap_handler: (e) ->
    e.preventDefault()
    e.stopPropagation()

    $(e.currentTarget).trigger("dblclick")



  #
  #  Controller knobs
  #
  setup_knobs: ($knobs) ->
    if $.os.tablet or $.os.phone
      # does not work on iOS
    else
      that = this
      $knobs.each(() -> that.setup_knob($(this)))



  setup_knob: ($knob) ->
    $knob.on("pointerdown", (e) ->
      $(document).on("pointermove", pointer_move)
                 .on("pointerup", pointer_up)
    )

    pointer_move = (e) =>
      angle = this.knob_get_angle($knob, e)
      item = _.without($knob.attr("class").split(" "), "knob")[0]
      biquad_filters = ["low", "mid", "hi"]
      function_arguments = []

      # mouse move event function & its arguments
      specific_mouse_move_event = if _.contains(biquad_filters, item)
        function_arguments.push(item, angle)
        this.knob_mouse_move_events.biquad_filter
      else
        function_arguments.push(angle)
        this.knob_mouse_move_events[item]

      # continue
      if specific_mouse_move_event
        specific_mouse_move_event.apply(this, function_arguments)


    pointer_up = (e) ->
      $(document).off("pointermove", pointer_move)
                 .off("pointerup", pointer_up)



  knob_get_angle: ($knob, e) ->
    $t = $knob.find(".it .layer-a")
    knob_x = $t.offset().left + $t.width() / 2
    knob_y = $t.offset().top + $t.height() / 2
    mouse_x = e.pageX
    mouse_y = e.pageY

    mx = mouse_x - knob_x
    my = mouse_y - knob_y
    kx = 0
    ky = 0

    # calculate angle
    if OngakuRyohoPreloadedData.user.settings.alternative_knob is "1"
      downwards = !(my < 0)
      percentage = Math.abs(my) / 70
      angle = 135 * percentage
      angle = -(angle) if downwards

    else
      distance = Math.sqrt(Math.pow(mx - kx, 2) + Math.pow(my - ky, 2))
      return if distance < 15

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
