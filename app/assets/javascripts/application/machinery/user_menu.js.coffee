class OngakuRyoho.Classes.Machinery.UserMenu

  constructor: () ->
    @timeout_ids = []



  #
  #  Timeouts
  #
  clear_timeouts: () =>
    array = @timeout_ids
    array_clone = _.clone(array)

    # loop and clear
    _.each(array_clone, (timeout_id) ->
      clearTimeout(timeout_id)
      array.shift()
    )



  set_timeout_for_hide: () =>
    @timeout_ids.push(
      setTimeout(@group.view.hide, 3000)
    )



  set_timeout_for_document_click: () =>
    this.group.machine.timeout_ids.push(
      setTimeout((() -> $(document).one("click", OngakuRyoho.UserMenu.view.hide)), 100)
    )



  #
  #  Theather mode
  #
  set_theater_mode_visibility: (state) ->
    animation_duration = 950

    # set elements
    $switch =  @group.view.$el.find("[rel=\"set-theater-mode\"]")
    $color_overlay = $("#color-overlay")

    # go
    if state is "off"
      $switch.removeClass("on")
      $color_overlay.fadeTo(animation_duration, 0)

    else
      $switch.addClass("on")
      $color_overlay.fadeTo(animation_duration, 1)

    # save state in local storage
    window.localStorage.setItem("theater_mode_state", state)



  theater_mode_toggle: (e) =>
    $t = $(e.currentTarget)

    if $t.hasClass("on")
      this.set_theater_mode_visibility("off")
    else
      this.set_theater_mode_visibility("on")



  check_theater_mode: () ->
    theater_mode_state = window.localStorage.getItem("theater_mode_state")
    theater_mode_state ?= "off"

    # set
    this.set_theater_mode_visibility(theater_mode_state)



  #
  #  Source manager
  #
  source_manager_toggle: (e) ->
    OngakuRyoho.SourceManager.view.show()
