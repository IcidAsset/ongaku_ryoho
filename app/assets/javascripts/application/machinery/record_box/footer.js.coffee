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



  #
  #  Track list settings
  #
  setup_track_list_settings_menu: () ->
    machine = this
    el = @group.view.$el.find(".track-list-settings .menu")

    @tooltip = new BareTooltip(el, {
      trigger_type: "click",
      tooltip_klass: "tooltip",
      animation_speed: 0,
      timeout_duration: 0,
      template: """
        <div class="{{CLASSES}}">
          <div class="arrow"></div>
          {{CONTENT}}
        </div>
      """,
      tooltip_data: """
        <div class="group first">
          <a rel="col_default">Artist/title/album</a>
          <a rel="col_file_location">File location</a>
        </div>
      """
    })

    # extend
    @tooltip.show_tooltip = () ->
      this.state.$tooltip_element.on("click", "a[rel=\"col_default\"]", machine.col_default)
      this.state.$tooltip_element.on("click", "a[rel=\"col_file_location\"]", machine.col_file_location)

      BareTooltip.prototype.show_tooltip.apply(this)

    @tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("click")

      BareTooltip.prototype.hide_tooltip.apply(this, arguments)

    @tooltip.move_tooltip = (e) ->
      $t = this.state.$tooltip_element
      $trigger = $(e.currentTarget)

      $t.css({
        left: $trigger.offset().left + Math.round($trigger.width() / 2) - Math.round($t.width() / 2),
        top: $trigger.offset().top + $trigger.height() / 2 + 15
      })

    # setup
    @tooltip.setup()


  col_default: (e) =>
    #


  col_file_location: (e) =>
    #



  #
  #  Other
  #
  intestines_span_dbl_click_handler: (e) ->
    number = parseInt(prompt("Go to page:"), 10)
    page_info = OngakuRyoho.RecordBox.Tracks.collection.page_info()
    return unless number

    if number < 1
      number = 1
    else if number > page_info.pages
      number = page_info.pages

    OngakuRyoho.RecordBox.Filter.model.set("page", number)
