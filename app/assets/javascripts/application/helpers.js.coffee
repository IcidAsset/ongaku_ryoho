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

    # disable ios background scroll
    $(document).on("touchmove", (e) ->
        target = e.target
        parent = $(target).closest(".tracks-wrapper")

        if parent.length is 0
          e.preventDefault()
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
  add_loading_animation: (target, color="#fff", radius=4) ->
    options =
      lines: 10
      length: 1
      width: 1
      radius: radius
      rotate: 90
      color: color
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



  #
  #  Async stuff
  #
  promise_fetch: (obj) ->
    promise = new RSVP.Promise()

    obj.fetch.call(obj, {
      success: (model, response) -> promise.resolve(response),
      error: promise.reject
    })

    return promise
