window.helpers =

  #
  #  Initialize (before)
  #
  initialize_before: () ->
    this.original_document_title = document.title

    # when the page loses focus, disable animations
    $(window).on("focus", helpers.enable_jquery_animations)
             .on("blur", helpers.disable_jquery_animations)


  #
  #  Initialize (after)
  #
  initialize_after: () ->
    this.check_theater_mode({ disable_animation: true })


  #
  #  CSS Helpers
  #
  css:
    rotate: ($el, degrees) ->
      css = {}

      css["-webkit-transform"] = "rotate(" + degrees + "deg)"
      css["-moz-transform"] = css["-webkit-transform"]
      css["-o-transform"] = css["-webkit-transform"]
      css["-ms-tranform"] = css["-webkit-transform"]

      $el.css(css)


  #
  #  Loading animation
  #
  add_loading_animation: ($target) ->
    options =
      lines: 6
      length: 3
      width: 1
      radius: 3
      rotate: 90
      color: "#fff"
      speed: 1
      trail: 60
      shadow: false

    spinner = new Spinner(options).spin($target[0])


  #
  #  Set document title
  #
  set_document_title: (text, set_original_title) ->
    this.original_document_title = document.title if set_original_title
    document.title = text


  #
  #  Enable / disable jQuery animations
  #
  enable_jquery_animations: -> $.fx.off = false
  disable_jquery_animations: -> $.fx.off = true


  #
  #  Set theather mode
  #
  set_theater_mode: (state, options={}) ->
    animation_duration = options.disable_animation ? 0 : 950

    # set elements
    $button = PlaylistView.$el.find(".navigation .button.theater-mode")
    $color_overlay = $("#color-overlay")

    # go
    if state is "off"
      $button.removeClass("on")
      $color_overlay.fadeOut(animation_duration)

    else
      $button.addClass("on")
      $color_overlay.fadeIn(animation_duration)

    # save state in local storage
    window.localStorage.setItem("theater_mode_state", state)


  #
  #  Check theather mode
  #
  check_theater_mode: (options={}) ->
    theater_mode_state = window.localStorage.getItem("theater_mode_state")

    # check
    helpers.set_theater_mode("on", options) if theater_mode_state is "on"
