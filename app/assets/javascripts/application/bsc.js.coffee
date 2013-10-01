#
#  Browser support checker
#
window.BSC =

  check: ->
    checks = [
      "boxshadow", "history",
      "localstorage", "postmessage",
      "flexbox", "webworkers", "svg"
    ]

    checks = _.map(checks, (item) -> Modernizr[item])
    passed = !_.contains(checks, false)

    # web audio api
    if typeof AudioContext is "undefined" and
       typeof webkitAudioContext is "undefined"
      passed = false

    # return
    return passed


  show_not_supported_message: ->
    html = """
      <div class="content">
        <p class="bold">
          This web application requires
          the following browser features:
        </p>
        <p>
          Web Audio API,
          HTML5 Audio,
          Cross-window Messaging,
          localStorage,
          Web Workers,
          CSS flexbox (latest spec),
          CSS box-shadow,
          SVG,
          etc.
        </p>
      </div>
      <div class="background"></div>
    """

    div = document.createElement("div")
    div.className = "mod-browser-not-supported"
    div.innerHTML = html

    body = document.getElementsByTagName("body")[0]
    body.appendChild(div)
