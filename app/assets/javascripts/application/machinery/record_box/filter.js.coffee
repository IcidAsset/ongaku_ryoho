class OngakuRyoho.Classes.Machinery.RecordBox.Filter

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

    query = $(e.currentTarget).find('input[type="text"]').val()
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



  extra_search_field_focus_handler: (e) =>
    @group.view.$el.addClass("is-using-extra-search-field")



  extra_search_field_blur_handler: (e) =>
    @group.view.$el.removeClass("is-using-extra-search-field")

    $t = $(e.currentTarget)
    $t.val("")



  #
  #  Other event handlers
  #
  cancel_default_click: (e) ->
    e.preventDefault()
    e.stopPropagation()
