class OngakuRyoho.Classes.Views.RecordBox.Filter extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .add-button.favourites"    : @group.machine.add_button_favourites_click_handler
    "click .item.favourites"          : @group.machine.item_favourites_click_handler

    "click .item.search"              : @group.machine.item_search_click_handler



  #
  #  Initialize
  #
  initialize: () ->
    super

    # elements
    btn_element = OngakuRyoho.RecordBox.Navigation.view.$el.find(".filter").get(0)
    this.setElement(btn_element)

    # templates
    @filter_item_template = Helpers.get_template("filter-item")

    # model events
    @group.model.on("change", this.render)
    @group.model.on("change:sort_by", @group.machine.sort_by_change_handler)
    @group.model.on("change:sort_direction", @group.machine.sort_by_change_handler)

    # machinery
    @group.machine.sort_by_change_handler()
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

    # search
    _.each(model.get("searches"), (search_query, idx) ->
      keyword = if idx > 0 then "AND" else false
      new_item = _this.new_item("search", search_query, "&#128269;", keyword)
      fragment.appendChild(new_item)
    )

    # favourites
    if model.get("favourites")
      new_item = _this.new_item("favourites", "favourites", "&#9733;")
      fragment.appendChild(new_item)

    # reset
    box_element.innerHTML = ""

    # add fragment to box
    if fragment.childNodes.length > 0
      box_element.appendChild(fragment)
    else



  new_item: (klass, text, icon, keyword) ->
    item_element = document.createElement("a")
    item_element.className = "item #{klass}"
    item_element.innerHTML = @filter_item_template({
      text: text,
      icon: icon,
      keyword: keyword
    })

    item_element
