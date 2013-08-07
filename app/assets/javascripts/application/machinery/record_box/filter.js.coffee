class OngakuRyoho.Classes.Machinery.RecordBox.Filter

  #
  #  Playlists
  #
  add_button_playlist_click_handler: () ->
    OngakuRyoho.RecordBox.PlaylistMenu.view.toggle()



  item_playlist_click_handler: () ->
    @group.model.disable_playlist()



  #
  #  Favourites
  #
  add_button_favourites_click_handler: () =>
    @group.model.toggle_favourites()



  item_favourites_click_handler: (e) =>
    @group.model.disable_favourites()



  #
  #  Search -> Tooltip
  #
  setup_search_tooltip: () ->
    _this = this
    $trigger = @group.view.$el.find(".add-button.search")

    # initialize
    @search_tooltip = new BareTooltip($trigger, {
      trigger_type: "click",
      tooltip_klass: "mod-search-menu tooltip",
      animation_speed: 0,
      timeout_duration: 0,
      template: '<div class="{{CLASSES}}">' +
        '<div class="arrow"></div>' +
        '{{CONTENT}}' +
      '</div>'
    })

    # extend / show
    @search_tooltip.show_tooltip = () ->
      this.state.$tooltip_element.on("submit", "form", _this.search_form_submit_handler)
      this.state.$tooltip_element.on("click", ".group", _this.cancel_default_click)
      this.state.$tooltip_element.on("click", ".submit", _this.search_form_submit_click_handler)
      this.state.$tooltip_element.on("click", "[data-action]", _this.search_form_action_click_handler)
      this.$el.addClass("active")

      BareTooltip.prototype.show_tooltip.apply(this)

    # extend / hide
    @search_tooltip.hide_tooltip = () ->
      this.state.$tooltip_element.off("submit")
      this.state.$tooltip_element.off("click")
      this.$el.removeClass("active")

      BareTooltip.prototype.hide_tooltip.apply(this, arguments)

    # extend / move
    @search_tooltip.move_tooltip = (e) ->
      $t = this.state.$tooltip_element
      $trigger = $(e.currentTarget)

      $t.css({
        left: $trigger.offset().left + Math.round($trigger.width() / 2) - Math.round($t.width() / 2),
        top: $trigger.offset().top + $trigger.height() + 12
      })

    # setup
    @search_tooltip.setup()



  search_form_submit_handler: (e) =>
    e.preventDefault()
    $form = $(e.currentTarget)

    # get query
    query = $form.find('input[type="text"]').val()

    # action?
    action_element = $form.find('[data-action].active')[0]

    if action_element
      switch action_element.getAttribute("data-action")
        when "add" then query = "+" + query
        when "subtract" then query = "-" + query

    # set query on model
    @group.model.add_search_query(query)



  search_form_submit_click_handler: (e) ->
    $(e.currentTarget).closest("form").trigger("submit")



  search_form_action_click_handler: (e) ->
    $t = $(e.currentTarget)

    if $t.hasClass("active")
      $t.removeClass("active")
    else
      $t.parent().children("div.active").removeClass("active")
      $t.addClass("active")



  #
  #  Search -> Items
  #
  item_search_click_handler: (e) =>
    query = $(e.currentTarget).attr("data-query")
    @group.model.remove_search_query(query)



  #
  #  Search -> Extra field
  #
  extra_search_field_form_submit_handler: (e) =>
    e.preventDefault()

    # set elements
    $input = $(e.currentTarget).children("input")

    # send query to model
    @group.model.add_search_query($input.val())

    # clean up
    $input.val("")
    $input[0].is_empty = true



  extra_search_field_focus_handler: (e) =>
    @group.view.$el.addClass("is-using-extra-search-field")

    # bind backspace action
    OngakuRyoho.People.KeyMaster.filter_extra_search_field_bind(e.currentTarget)



  extra_search_field_blur_handler: (e) =>
    @group.view.$el.removeClass("is-using-extra-search-field")

    # unbind backspace action
    OngakuRyoho.People.KeyMaster.filter_extra_search_field_unbind(e.currentTarget)

    # clean input
    $t = $(e.currentTarget)
    $t.val("")



  #
  #  Other event handlers
  #
  cancel_default_click: (e) ->
    e.preventDefault()
    e.stopPropagation()
