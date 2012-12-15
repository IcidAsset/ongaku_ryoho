class OngakuRyoho.Classes.Machinery.UserMenu

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
