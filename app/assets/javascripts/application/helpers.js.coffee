window.Helpers =

  #
  #  Initialize (before)
  #
  initialize_before: () ->
    this.original_document_title = document.title

    # handlebars
    this.setup_handlebars_helpers()

    # request animation frame
    window.requestAnimationFrame = (
      window.requestAnimationFrame ||
      window.webkitRequestAnimationFrame ||
      window.mozRequestAnimationFrame
    )

    window.cancelAnimationFrame = (
      window.cancelAnimationFrame ||
      window.webkitCancelRequestAnimationFrame ||
      window.mozCancelRequestAnimationFrame
    )



  #
  #  Setup handlebars helpers
  #
  setup_handlebars_helpers: () ->
    # icons
    Handlebars.registerHelper("if_has_icon", (block) ->
      return block(this) if @icon and @icon_type
    )

    # sources
    Handlebars.registerHelper("source_subtext", () ->
      if @status.match(/(unprocessed|processing)/gi) isnt null
        "<span>#{@status}</span>"
      else
        "<span>#{@track_amount} tracks</span>"
    )



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
  add_loading_animation: (target) ->
    options =
      lines: 10
      length: 1
      width: 1
      radius: 4
      rotate: 90
      color: "#fff"
      speed: 1
      trail: 60
      shadow: false

    spinner = new Spinner(options).spin(target)



  #
  #  Set document title
  #
  set_document_title: (text, set_original_title) ->
    this.original_document_title = document.title if set_original_title
    document.title = text
