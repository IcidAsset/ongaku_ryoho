class OngakuRyoho.Classes.Views.RecordBox.Filter extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .add-button.playlist"        : @group.machine.add_button_playlist_click_handler
    "click .add-button.favourites"      : @group.machine.add_button_favourites_click_handler
    "click .item.playlist"              : @group.machine.item_playlist_click_handler
    "click .item.favourites"            : @group.machine.item_favourites_click_handler
    "click .item.search"                : @group.machine.item_search_click_handler

    "submit .extra-search-field"        : @group.machine.extra_search_field_form_submit_handler
    "focus .extra-search-field input"   : @group.machine.extra_search_field_focus_handler
    "blur .extra-search-field input"    : @group.machine.extra_search_field_blur_handler



  #
  #  Initialize
  #
  initialize: () ->
    super("Filter")

    # elements
    el = OngakuRyoho.RecordBox.Navigation.view.el.querySelector(".filter")
    this.setElement(el)

    esf_input = this.el.querySelector(".extra-search-field input")
    esf_input.is_empty = true

    # templates
    @filter_item_template = Helpers.get_template("filter-item")

    # model events
    this.listenTo(@group.model, "change", this.render)

    # etc
    this.render()
    this.group.machine.setup_search_tooltip()
    this.group.machine.setup_showmore_tooltip()

    # other events
    $(window).on("resize.filter_view", _.debounce(this.window_resize_handler, 250))



  window_resize_handler: (e) =>
    this.render()



  #
  #  Render
  #
  render: () =>
    this.el.querySelector(".box").classList.remove("visible")

    setTimeout(this.render_deux, 125 + 100)



  render_deux: () =>
    fragment = document.createDocumentFragment()

    # playlist
    if @group.model.get("playlist")
      title = @group.model.get("playlist_name")
      new_item = this.new_item("playlist", title, "&#57349;")
      fragment.appendChild(new_item)

    # favourites
    if @group.model.get("favourites")
      new_item = this.new_item("favourites", "favourites", "&#9733;")
      fragment.appendChild(new_item)

    # search
    _.each(@group.model.get("searches"), (query, idx) =>
      text = query

      if query.charAt(0) is "!"
        keyword = "NOT"
        text = query.substr(1)
      else if idx > 0
        keyword = "AND"

      new_item = this.new_item("search", text, "&#128269;", keyword, query)
      fragment.appendChild(new_item)
    )

    # reset
    box_element = this.el.querySelector(".box")
    box_element.innerHTML = ""

    # add fragment to box
    if fragment.childNodes.length > 0
      box_element.appendChild(fragment)
      this.el.classList.remove("is-empty")
      setTimeout((=> this.after_render(box_element)), 0)
    else
      this.el.classList.add("is-empty")



  after_render: (box_element) ->
    max_w = Math.floor(this.el.offsetWidth * .6) - (33 + 2 + 10)
    w = 0
    show_more = off
    show_more_nodes = []

    # show more nodes
    $(box_element).children("a.item").each ->
      child_node = this
      w = w + child_node.offsetWidth

      if show_more
        n = $(child_node).remove().get(0)
      else if w >= max_w
        n = $(child_node).remove().get(0)
        show_more = on

      if n
        show_more_nodes.push(n)

    # if show more
    if show_more
      show_more_html = ""

      for show_more_node in show_more_nodes
        type = show_more_node.getAttribute("data-type")
        query = show_more_node.getAttribute("data-query")

        show_more_html = show_more_html + """
          <a class="with-icon" data-type="#{type}" data-query="#{query}">
            #{show_more_node.innerHTML}
          </a>
        """

      show_more_button = document.createElement("a")
      show_more_button.className = "show-more-button"
      show_more_button.innerHTML = "&#59236"

      tooltip_data = document.createElement("div")
      tooltip_data.className = "tooltip-data"
      tooltip_data.innerHTML = """
        <div class="group first">
          #{show_more_html}
        </div>
      """

      box_element.appendChild(show_more_button)
      box_element.appendChild(tooltip_data)

    # show box items
    box_element.classList.add("visible")



  new_item: (klass, text, icon, keyword, query) ->
    item_element = document.createElement("a")
    item_element.className = "item #{klass}"
    item_element.innerHTML = @filter_item_template({
      text: text,
      icon: icon,
      keyword: keyword
    })

    item_element.setAttribute("data-type", klass)
    item_element.setAttribute("data-query", query) if query
    item_element
