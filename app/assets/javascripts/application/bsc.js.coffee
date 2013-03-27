#
#  Browser support checker
#
window.BSC =

  check: ->
    checks = [
      "boxshadow", "history",
      "localstorage", "postmessage",
      "webworkers", "svg"
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
        <p>
          This web application requires
          the following browser features:
        </p>
        <ul>
          <li><span>Web Audio API</span></li>
          <li><span>HTML5 Audio</span></li>
          <li><span>Cross-window Messaging</span></li>
          <li><span>localStorage</span></li>
          <li><span>Web Workers</span></li>
          <li><span>CSS flexbox (latest spec)</span></li>
          <li><span>CSS box-shadow</span></li>
          <li><span>SVG</span></li>
        </ul>
      </div>
    """

    div = document.createElement("div")
    div.className = "mod-browser-not-supported"
    div.innerHTML = html

    body = document.getElementsByTagName("body")[0]
    body.appendChild(div)
