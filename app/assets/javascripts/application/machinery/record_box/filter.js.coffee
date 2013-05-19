class OngakuRyoho.Classes.Machinery.RecordBox.Filter

  #
  #  Favourites
  #
  toggle_favourites: () =>
    @group.model.set("favourites", !@group.model.get("favourites"))


  disable_favourites: () ->
    @group.model.set("favourites", off)


  item_favourites_click_handler: (e) =>
    this.disable_favourites()



  #
  #  Search
  #
  setup_search_tooltip: () ->
    _this = this
    $trigger = @group.view.$el.find(".add-button.search")

    # initialize
    @search_tooltip = new BareTooltip($trigger, {
      trigger_type: "click",
      tooltip_klass: "tooltip",
      animation_speed: 0,
      timeout_duration: 0,
      template: '<div class="{{CLASSES}}">' +
        '<div class="arrow"></div>' +
        '{{CONTENT}}' +
      '</div>'
    })

    # extend / show
    @search_tooltip.show_tooltip = () ->
      this.state.$tooltip_element.on("click", ".group", _this.cancel_default_click)
      this.state.$tooltip_element.on("submit", "form", _this.search_form_submit_handler)

      BareTooltip.prototype.show_tooltip.apply(this)

    # extend / hide
    @search_tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("click")
      this.state.$tooltip_element.off("submit")

      BareTooltip.prototype.hide_tooltip.apply(this, arguments)

    # extend / move
    @search_tooltip.move_tooltip = (e) ->
      $t = this.state.$tooltip_element
      $trigger = $(e.currentTarget)

      $t.css({
        left: $trigger.offset().left + Math.round($trigger.width() / 2) - Math.round($t.width() / 2),
        top: $trigger.offset().top + $trigger.height() + 9
      })

    # setup
    @search_tooltip.setup()


  search_form_submit_handler: (e) =>
    e.preventDefault()

    # reset page
    @group.model.set("page", 1)

    # search
    query = $(e.currentTarget).find('input[type="search"]').val()
    @group.model.add_search_query(query) if query


  item_search_click_handler: (e) =>
    query = $(e.currentTarget).find(".text").text()
    @group.model.remove_search_query(query)



  #
  #  Other event handlers
  #
  fetch_tracks: () ->
    return unless OngakuRyoho.People.ViewStateManager.state.ready
    OngakuRyoho.RecordBox.Tracks.collection.fetch({ reset: true })


  sort_by_change_handler: (e) ->
    OngakuRyoho.RecordBox.Navigation.machine.add_active_class_to_selected_sort_by_column()


  cancel_default_click: (e) ->
    e.preventDefault()
    e.stopPropagation()
