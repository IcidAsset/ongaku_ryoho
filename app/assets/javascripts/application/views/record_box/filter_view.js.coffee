class OngakuRyoho.Classes.Views.RecordBox.Filter extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .add-button.favourites"      : @group.machine.add_button_favourites_click_handler
    "click .item.favourites"            : @group.machine.item_favourites_click_handler
    "click .item.search"                : @group.machine.item_search_click_handler

    "submit .extra-search-field"        : @group.machine.extra_search_field_form_submit_handler
    "focus .extra-search-field input"   : @group.machine.extra_search_field_focus_handler
    "blur .extra-search-field input"    : @group.machine.extra_search_field_blur_handler



  #
  #  Initialize
  #
  initialize: () ->
    super

    # elements
    menu_btn_element = OngakuRyoho.RecordBox.Navigation.view.$el.find(".filter")[0]
    this.setElement(menu_btn_element)

    # templates
    @filter_item_template = Helpers.get_template("filter-item")

    # model events
    @group.model.on("change", this.render)

    # machinery
    @group.machine.setup_search_tooltip()

    # render
    this.render()



  #
  #  Render
  #
  render: () =>
    _this = this
    model = @group.model
    box_element = this.$el.children(".box")[0]
    fragment = document.createDocumentFragment()

    # playlist
    # -> todo

    # favourites
    if model.get("favourites")
      new_item = _this.new_item("favourites", "favourites", "&#9733;")
      fragment.appendChild(new_item)

    # search
    _.each(model.get("searches"), (query, idx) ->
      text = query

      if query.charAt(0) is "!"
        keyword = "NOT"
        text = query.substr(1)
      else if idx > 0
        keyword = "AND"

      new_item = _this.new_item("search", text, "&#128269;", keyword, query)
      fragment.appendChild(new_item)
    )

    # reset
    box_element.innerHTML = ""

    # add fragment to box
    if fragment.childNodes.length > 0
      box_element.appendChild(fragment)
      this.$el.removeClass("is-empty")
    else
      this.$el.addClass("is-empty")



  new_item: (klass, text, icon, keyword, query) ->
    item_element = document.createElement("a")
    item_element.className = "item #{klass}"
    item_element.innerHTML = @filter_item_template({
      text: text,
      icon: icon,
      keyword: keyword
    })

    item_element.setAttribute("data-query", query) if query
    item_element
