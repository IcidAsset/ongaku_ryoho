class OngakuRyoho.Classes.Views.RecordBox.Tracks extends Backbone.View

  dragged_track_element: null
  mode: "default"



  #
  #  Events
  #
  events: () ->
    "click .track .favourite"  : @group.machine.track_rating_star_click
    "dragstart .track"         : @group.machine.track_dragstart
    "dragend .track"           : @group.machine.track_dragend
    "dragenter .track"         : @group.machine.track_dragenter
    "dragleave .track"         : @group.machine.track_dragleave
    "dragover .track"          : @group.machine.track_dragover
    "drop .track"              : @group.machine.track_drop

    "dragenter .group"         : @group.machine.group_dragenter
    "dragleave .group"         : @group.machine.group_dragleave
    "dragover .group"          : @group.machine.group_dragover
    "drop .group"              : @group.machine.group_drop



  #
  #  Initialize
  #
  initialize: () ->
    @parent_group = OngakuRyoho.RecordBox
    @group = @parent_group.Tracks
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.RecordBox.Tracks
    @group.machine.group = @group
    @group.machine.parent_group = @parent_group

    # this element
    this.setElement($("#record-box").find(".tracks-wrapper")[0])

    # templates
    @track_template = Helpers.get_template("track")
    @message_template = Helpers.get_template("list-message")

    # add loading message
    this.add_loading_message()

    # render
    @group.collection
      .on("reset", this.render)
      .on("remove", this.remove_handler)

    # fetch events
    @group.collection
      .on("fetched", @group.machine.fetched)

    # tap events
    double_tap_hammer = Hammer(this.el)
    double_tap_hammer.on "doubletap", (e) =>
      @group.machine.activate_track($(e.target).closest(".track")[0])

    # scroll/touch events
    scroll_el = this.el
    scroll_el.addEventListener("touchstart", (e) ->
        start_y = e.touches[0].pageY;
        start_top_scroll = e.scrollTop;

        scroll_el.scrollTop = 1 if start_top_scroll <= 0

        if start_top_scroll + scroll_el.offsetHeight >= scroll_el.scrollHeight
          scroll_el.scrollTop = scroll_el.scrollHeight - scroll_el.offsetHeight - 1;
    , false)



  #
  #  Render
  #
  render: () =>
    list_element = document.createElement("ol")
    list_element.classList.add("tracks")

    # render
    list_fragment = this["render_#{this.mode}"](list_element)
    list_element.appendChild(list_fragment)

    # scroll to top
    this.el.scrollTop = 0

    # add list to main elements
    this.el.innerHTML = ""
    this.el.appendChild(list_element)

    # add background to main elements
    background = document.createElement("div")
    background.classList.add("background")
    this.el.appendChild(background)

    # check
    if $(list_element).children("li").length is 0
      this.add_nothing_here_message()
      OngakuRyoho.RecordBox.Footer.view.set_contents("")

    # chain
    return this



  render_default: (list_element) =>
    page_info = @group.collection.page_info()
    list_fragment = document.createDocumentFragment()
    track_template = @track_template

    # tracks
    @group.collection.each((track) ->
      track_view = new OngakuRyoho.Classes.Views.RecordBox.Track({ model: track })
      list_fragment.appendChild(track_view.render(track_template).el)
    )

    # set footer contents
    word_tracks = (if page_info.total is 1 then "track" else "tracks")
    message = "#{page_info.total} #{word_tracks} found &mdash; page #{page_info.page} / #{page_info.pages}"

    OngakuRyoho.RecordBox.Footer.view.set_contents(message)

    # return list fragment
    return list_fragment



  render_queue: (list_element) =>
    queue = OngakuRyoho.Engines.Queue
    message = "Queue &mdash; The next #{queue.data.combined_next.length} items"
    list_fragment = document.createDocumentFragment()
    track_template = @track_template

    # group
    group = document.createElement("li")
    group.classList.add("group")
    group.innerHTML = "<span>Queue</span>"
    list_fragment.appendChild(group)

    # tracks
    _.each(queue.data.combined_next, (map) ->
      return unless map.track
      track_view = new OngakuRyoho.Classes.Views.RecordBox.Track({ model: map.track })
      track_view.el.classList.add("queue-item")
      track_view.el.classList.add("user-selected") if map.user

      list_fragment.appendChild(track_view.render(track_template).el)
    )

    # set foorter contents
    OngakuRyoho.RecordBox.Footer.view.set_contents(message)

    # return list fragment
    return list_fragment



  remove_handler: (track) =>
    this.$el.find(".track[rel=\"#{track.id}\"]").remove()



  #
  #  Messages, info, etc.
  #
  add_nothing_here_message: () ->
    sources_collection = OngakuRyoho.SourceManager.collection

    message = if sources_collection.length is 0
      "You haven't added a music source yet."
    else if sources_collection.where({ available: true }).length is 0
      "All sources are offline."
    else if @group.collection.filter.length > 0
      "No search results."
    else
      "Empty collection."

    message_html = @message_template(
      title: "NOTHING FOUND"
      message: message
      extra_html: ""
      extra_classes: "nothing-here"
    )

    this.$el.append(message_html)



  add_loading_message: () ->
    $loading = $("<div class=\"message loading\" />")
    $loading.append("<span><span class=\"animation\"></span>loading ...</span>")
    $loading.appendTo(this.$el)

    Helpers.add_loading_animation(
      this.$el.find(".loading .animation")[0],
      "#000", 4
    )
