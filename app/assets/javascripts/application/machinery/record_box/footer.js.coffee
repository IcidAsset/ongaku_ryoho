class OngakuRyoho.Classes.Machinery.RecordBox.Footer

  #
  #  Page navigation
  #
  previous_page_button_click_handler: (e) ->
    OngakuRyoho.RecordBox.Tracks.collection.go_to_previous_page()



  next_page_button_click_handler: (e) ->
    OngakuRyoho.RecordBox.Tracks.collection.go_to_next_page()



  check_page_navigation: () ->
    page_info = OngakuRyoho.RecordBox.Tracks.collection.page_info()
    $previous = @group.view.$el.find("footer .page-nav .previous")
    $next = @group.view.$el.find("footer .page-nav .next")

    # check
    unless page_info.prev then $previous.addClass("disabled")
    else $previous.removeClass("disabled")

    unless page_info.next then $next.addClass("disabled")
    else $next.removeClass("disabled")



  disable_navigation_entirely: () ->
    @group.view.$el
      .find("footer .page-nav")
      .find(".previous, .next")
      .addClass("disabled")



  intestines_span_dbl_click_handler: (e) ->
    number = parseInt(prompt("Go to page:"), 10)
    page_info = OngakuRyoho.RecordBox.Tracks.collection.page_info()
    return unless number

    if number < 1
      number = 1
    else if number > page_info.pages
      number = page_info.pages

    OngakuRyoho.RecordBox.Filter.model.set("page", number)
