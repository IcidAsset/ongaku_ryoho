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

    # ios homescreen app
    if $.os.ios and ("standalone" in window.navigator) and !window.navigator.standalone
      passed = false

    # return
    return passed


  show_not_supported_message: ->
    title = "Hold on"

    if $.os.ios
      other = """
        If you want to use this application on iOS,
        you will have to add it to your homescreen.
      """

    # the html
    if other
      html = """
        <div class="content">
          <h2>#{title}</h2>
          <p>
            #{other}
          </p>
        </div>
      """
    else
      html = """
        <div class="content">
          <h2>#{title}</h2>
          <p>
            <strong>This web application requires
            the following browser features:</strong><br>
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
      """

    # background
    html = html + """
      <div class="background"></div>
    """

    # the rest
    div = document.createElement("div")
    div.className = "mod-browser-not-supported"
    div.innerHTML = html

    body = document.getElementsByTagName("body")[0]
    body.appendChild(div)


  perform_other_checks: ->
    # tablet / phone
    if $.os.tablet or $.os.phone
      $(".knob.volume").parent().css("opacity", "0.25")
      $(".switch.volume").parent().css("opacity", "0.25")
      $(".controls.alt").find("a, .subtitle").css("opacity", "0.25")
