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
  setup_tls_menu: () ->
    machine = this
    el = @group.view.$el.find(".track-list-settings .menu")

    @tooltip = new BareTooltip(el, {
      trigger_type: "click",
      tooltip_klass: "mod-track-list-settings-menu tooltip inverse grey",
      animation_speed: 0,
      timeout_duration: 0,
      tooltip_data: this.tls_tooltip_data_html
    })

    # extend
    @tooltip.show_tooltip = () ->
      this.state.$tooltip_element.on("click", "a[rel^=\"data--\"]", machine.tls_tooltip_data_click_handler)
      # this.state.$tooltip_element.find("[rel^=\"data--\"]")

      BareTooltip.prototype.show_tooltip.apply(this)

    @tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("click")

      BareTooltip.prototype.hide_tooltip.apply(this, arguments)

    @tooltip.move_tooltip = (e) ->
      $t = this.state.$tooltip_element
      $trigger = $(e.currentTarget)

      $t.css({
        left: $trigger.offset().left + Math.round($trigger.width() / 2) - Math.round($t.width() / 2) - 41,
        top: $trigger.offset().top - $t.height()
      })

    # setup
    @tooltip.setup()



  tls_tooltip_data_html: () =>
    template = """
      <div class="group first">
        <div class="group-label">Data</div>
        <a rel="data--default"><div class="checkbox"></div>Artist/title/album</a>
        <a rel="data--location"><div class="checkbox"></div>Location</a>
        <div class="group-label">Group by</div>
        <a rel="group--default">None <small>(default)</small></a>
        <a rel="group--directory">Directory</a>
        <a rel="group--date">Added-to-collection date</a>
      </div>
    """



  tls_tooltip_data_click_handler: (e) =>
    d = e.currentTarget.getAttribute("rel").replace("data--", "")
    OngakuRyoho.RecordBox.TLS.model.set("data", d)



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
