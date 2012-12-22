window.Legacy =

  initialize: () ->
    self = this

    # check
    this.check()

    # events
    $(window).on("resize", (e) -> self.check(true))



  check: (window_resize=false) ->
    checks = [
      "flexbox"
    ]

    window_resize_checks = [
      "flexbox"
    ]

    exec_check = (check) =>
      this["legacy_#{check}"]() unless Modernizr[check]

    if window_resize
      _.each(window_resize_checks, (check) -> exec_check(check))
    else
      _.each(checks, (check) -> exec_check(check))



  legacy_flexbox: () ->
    console.log("no (new) flexbox!")

    # set
    record_box = OngakuRyoho.RecordBox

    # record box navigation
    rb_nav_view = record_box.Navigation.view
    rb_nav_view.$el.find(".button, .input-wrap").css("float", "left")

    search_width = rb_nav_view.$el.children("nav").width() - 2
    search_width = search_width - 2 * parseInt(rb_nav_view.$el.children("nav").css("padding-left"), 10)

    rb_nav_view.$el.find(".button, .input-wrap:not(.search)").each(() ->
      search_width = search_width - $(this).width() - parseInt($(this).css("margin-left"), 10)
    )

    rb_nav_view.$el.find(".input-wrap.search").width(search_width)

    # record box tracks
    rb_tracks_view = record_box.Tracks.view
    rb_tracks_view.$el.height(400)
