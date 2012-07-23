###

     ____                    __            ____              __
    / __ \____  ____ _____ _/ /____  __   / __ \__  ______  / /_  ____
   / / / / __ \/ __ `/ __ `/ #_ / / / /  / /_/ / / / / __ \/ __ \/ __ \
  / /_/ / / / / /_/ / /_/ / ,< / /_/ /  / _, _/ /_/ / /_/ / / / / /_/ /
  \____/_/ /_/\__, /\__,_/_/|_|\__,_/  /_/ |_|\__, /\____/_/ /_/\____/
             /____/                          /____/


  Pages JS file with a touch of sprockets (.*)

###

#= require 'zepto'
#= require 'underscore'
#= require 'jsdeferred'
#= require 'spin'



$(document).ready ->
  slideshow.initialize()



#
#  Slideshow
#
slideshow = {

  initialize: () ->
    $slideshows = $(".slideshow")

    # prepare
    $slideshows.data("ready", false)

    # load slides
    $slideshows.each(slideshow.load_slides)

    # setup events
    $slideshows.find(".slide-navigation a")
               .on("click", slideshow.nav_item_click)

    $slideshows.find(".slide")
               .on("click", slideshow.slide_click)


  load_slides: () ->
    $slideshow = $(this)
    $images = $slideshow.find(".slide img")

    loading = _.map($images, (image) ->
      return () -> slideshow.load_image(image)
    )

    Deferred.chain(loading).next(() ->
      $slideshow.find(".slide-navigation a:first-child").addClass("active")
      $images = $slideshow.find(".slide img")
      $images.first().fadeTo(250, 1, () ->
        $images.removeAttr("style")
        $slideshow.data("ready", true)
      )
    )


  load_image: (image) ->
    dfd = new Deferred()

    $old_image = $(image)
    $new_image = $(new Image())
    $slide = $old_image.parent()
    src = $(image).data("src")

    $new_image
      .css("opacity", "0")
      .on("load", (e) ->
        dfd.call($new_image)
      )

    $new_image.attr("src", src)
    $new_image.appendTo($slide)
    $old_image.remove()

    return dfd


  go_to_slide: (index, $slideshow) ->
    $nav = $slideshow.find(".slide-navigation")
    $wrapper = $slideshow.find(".slides-wrapper")

    # position
    position = index * $slideshow.width()

    # animate
    $wrapper.animate({
      textIndent: "-#{position}px"
    }, 250)

    # nav
    $nav.find(".active").removeClass("active")
    $nav.find("a").eq(index).addClass("active")


  nav_item_click: (e) ->
    $t = $(this)
    $nav = $t.parent()
    $slideshow = $nav.closest(".slideshow")

    # go to slide
    slideshow.go_to_slide($t.index(), $slideshow)

    # prevent default
    e.preventDefault()
    return false


  slide_click: (e) ->
    $t = $(this)
    $wrapper = $t.parent()
    $slideshow = $wrapper.parent()

    return unless $slideshow.data("ready")

    slides_length = $wrapper.children(".slide").length
    index = $t.index()

    next_index = index + 1
    next_index = 0 if next_index == slides_length

    slideshow.go_to_slide(next_index, $slideshow)
}
