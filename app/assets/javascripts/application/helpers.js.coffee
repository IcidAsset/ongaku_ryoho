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

    # pointerevents drag & drop
    this.pedd = new PointerEventsDragnDrop(
      document.body, {
        delegate_selector: "[draggable]"
      }
    );

    # disable ios background scroll
    $(document).on("touchmove", (e) ->
        target = e.target
        parent = $(target).closest(".tracks-wrapper")
        e.preventDefault() if parent.length is 0
    )

    # send csrf-token when doing ajax request
    OngakuRyoho.csrf_token = $("meta[name=\"csrf-token\"]").attr("content")

    $.ajaxSettings.beforeSend = (xhr, settings) ->
      return if (settings.crossDomain)
      return if (settings.type == "GET")
      if (OngakuRyoho.csrf_token)
        xhr.setRequestHeader("X-CSRF-Token", OngakuRyoho.csrf_token)



  #
  #  Get template
  #
  get_template: (template_name) ->
    html = $("[data-template-name=\"#{template_name}\"]").html()
    return Handlebars.compile(html)



  #
  #  Set view element
  #
  set_view_element: (view, element) ->
    element = if typeof element is String
      document.querySelector(element)
    else
      element

    view.setElement(element)



  #
  #  Setup handlebars helpers
  #
  setup_handlebars_helpers: () ->
    # icons
    Handlebars.registerHelper("if_has_icon", (block) ->
      return block(this) if @icon and @icon_type
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
      css["transform"] = css["-webkit-transform"]

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
      success: (model, response) -> promise.resolve(response)
      error: -> promise.reject()
    })

    return promise
