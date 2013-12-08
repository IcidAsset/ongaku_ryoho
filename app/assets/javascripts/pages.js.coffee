###

     ____                    __            ____              __
    / __ \____  ____ _____ _/ /____  __   / __ \__  ______  / /_  ____
   / / / / __ \/ __ `/ __ `/ #_ / / / /  / /_/ / / / / __ \/ __ \/ __ \
  / /_/ / / / / /_/ / /_/ / ,< / /_/ /  / _, _/ /_/ / /_/ / / / / /_/ /
  \____/_/ /_/\__, /\__,_/_/|_|\__,_/  /_/ |_|\__, /\____/_/ /_/\____/
             /____/                          /____/


  Pages JS file

###

#= require "zepto"



$ ->
  $(document).on("click", ".remove-account a", remove_account_click_handler)
  setup_mobile_safari()



remove_account_click_handler = (e) =>
  if confirm("Are you sure?") is true
    $.ajax(
      type: "GET",
      url: "/sign-dead",
      data: "confirm=1",
      success: redirect,
      error: redirect
    )



redirect = () ->
  window.location = "/about"



setup_mobile_safari = () ->
  # prevents links from apps from opening in mobile safari
  standalone = "standalone"

  if (standalone in navigator) and navigator[standalone]
    curnode = no
    location = document.location
    stop = /^(a|html)$/i

    document.addEventListener("click", (e) ->
      chref = curnode.href
      curnode = e.target

      while !(stop).test(curnode.nodeName)
        curnode = curnode.parentNode

      cond_a = "href" in curnode
      cond_b = chref.replace(location.href, "").indexOf("#")
      cond_c = !(/^[a-z\+\.\-]+:/i).test(chref)
      cond_d = chref.indexOf(location.protocol + "//" + location.host) isnt 0

      if cond_a and cond_b and (cond_c or cond_d)
        e.preventDefault()
        location.href = curnode.href
    , false)
