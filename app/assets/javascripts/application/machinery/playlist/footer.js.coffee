class OngakuRyoho.Classes.Machinery.Playlist.Footer

  #
  #  Page navigation
  #
  previous_page_button_click_handler: (e) =>
    OngakuRyoho.Playlist.Tracks.collection.previous_page()



  next_page_button_click_handler: (e) =>
    OngakuRyoho.Playlist.Tracks.collection.next_page()



  check_page_navigation: () =>
    page_info = OngakuRyoho.Playlist.Tracks.collection.page_info()
    $previous = @group.view.$el.find("footer .page-nav .previous")
    $next = @group.view.$el.find("footer .page-nav .next")

    # check
    unless page_info.prev then $previous.addClass("disabled")
    else $previous.removeClass("disabled")

    unless page_info.next then $next.addClass("disabled")
    else $next.removeClass("disabled")
