class OngakuRyoho.Classes.Views.RecordBox.Tracks extends Backbone.View

  dragged_track_element: null
  mode: "default"



  #
  #  Events
  #
  events: () ->
    "dblclick .track"               : @group.machine.track_dblclick_handler
    "doubleTap .track"              : @group.machine.track_dblclick_handler

    "click .track .favourite"       : @group.machine.track_rating_star_click

    "pointerdragstart .track"       : @group.machine.track_pointerdragstart
    "pointerdragend .track"         : @group.machine.track_pointerdragend
    "pointerdragenter .track"       : @group.machine.track_pointerdragenter
    "pointerdragleave .track"       : @group.machine.track_pointerdragleave
    "pointerdrop .track"            : @group.machine.track_pointerdrop

    "pointerdragenter .group"       : @group.machine.group_pointerdragenter
    "pointerdragleave .group"       : @group.machine.group_pointerdragleave
    "pointerdrop .group"            : @group.machine.group_pointerdrop

    "click [rel=\"add-source\"]"    : @group.machine.add_source_click_handler



  #
  #  Initialize
  #
  initialize: () ->
    super("Tracks")

    # this element
    Helpers.set_view_element(this, ".mod-record-box .tracks-wrapper")

    # templates
    @track_default_template = Helpers.get_template("track-default")
    @track_location_template = Helpers.get_template("track-location")
    @message_template = Helpers.get_template("list-message")

    # add loading message
    this.add_loading_message()

    # prerequisites
    this.set_list_data_attr()

    # render
    this.listenTo(@group.collection, "reset", this.render)
    this.listenTo(@group.collection, "remove", this.remove_handler)

    # fetch events
    this.listenTo(@group.collection, "fetching", @group.machine.fetching)
    this.listenTo(@group.collection, "fetched", @group.machine.fetched)

    # tooltip
    @group.machine.setup_tooltip()



  #
  #  Render
  #
  render: () =>
    list_element = document.createElement("ol")
    list_element.className = "tracks"

    # render
    list_fragment = this["render_#{this.mode}_mode"]()
    list_element.appendChild(list_fragment)

    # position column
    a = (typeof OngakuRyoho.RecordBox.Filter.model.get("playlist") is "number")
    b = (this.mode is "default")

    if a and b
      this.el.parentNode.classList.add("with-position-column")
    else
      this.el.parentNode.classList.remove("with-position-column")

    # scroll to top
    this.el.scrollTop = 0

    # add list to main elements
    this.el.innerHTML = ""
    this.el.appendChild(list_element)

    # add background to main elements
    background = document.createElement("div")
    background.className = "background"
    this.el.appendChild(background)

    # check
    if list_element.childNodes.length is 0
      this.add_nothing_here_message()
      OngakuRyoho.RecordBox.Footer.view.set_contents("")

    # chain
    return this



  render_default_mode: () ->
    if this.requires_playlist_layout()
      this.render_playlist_layout()
    else
      this.render_default_layout()



  render_default_layout: () ->
    page_info = @group.collection.page_info()
    list_fragment = document.createDocumentFragment()
    track_template = this.get_correct_track_template()

    # render tracks
    @group.collection.each((track) ->
      track_view = new OngakuRyoho.Classes.Views.RecordBox.Track({ model: track })
      list_fragment.appendChild(track_view.render(track_template).el)
    )

    # set footer contents
    word_tracks = (if page_info.total is 1 then "track" else "tracks")
    message = "#{page_info.total} #{word_tracks} found &mdash; page #{page_info.page} / #{page_info.pages}"

    OngakuRyoho.RecordBox.Footer.view.set_contents(message)

    # return
    list_fragment



  render_playlist_layout: (list_fragment) ->
    page_info = @group.collection.page_info()
    list_fragment = document.createDocumentFragment()
    track_template = this.get_correct_track_template()

    # collect
    filter_playlist = OngakuRyoho.RecordBox.Filter.model.get("playlist")
    filter_desc = (OngakuRyoho.RecordBox.Filter.model.get("sort_direction") is "desc")
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(filter_playlist)
    tracks_with_position = playlist.get("tracks_with_position")

    # tracks
    _.each(tracks_with_position, (pt) ->
      track = OngakuRyoho.RecordBox.Tracks.collection.get(pt.track_id)
      track_view = new OngakuRyoho.Classes.Views.RecordBox.Track({ model: track }) if track
      list_fragment.appendChild(track_view.render(track_template, pt).el) if track
    )

    # set footer contents
    word_tracks = (if tracks_with_position.length is 1 then "track" else "tracks")
    message = "#{tracks_with_position.length} #{word_tracks} found &mdash; page #{page_info.page} / #{page_info.pages}"

    OngakuRyoho.RecordBox.Footer.view.set_contents(message)

    # return
    list_fragment



  render_queue_mode: (list_element) ->
    queue = OngakuRyoho.Engines.Queue
    message = "Queue &mdash; The next #{queue.data.combined_next.length} items"
    list_fragment = document.createDocumentFragment()
    track_template = this.get_correct_track_template()

    # group
    group = document.createElement("li")
    group.className = "group"
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

    # return
    list_fragment



  #
  #  Other
  #
  remove_handler: (track) =>
    this.$el.find(".track[rel=\"#{track.id}\"]").remove()



  get_correct_track_template: () ->
    d = OngakuRyoho.RecordBox.TLS.model.attributes.data
    this["track_#{d}_template"]



  set_list_data_attr: () ->
    tls = OngakuRyoho.RecordBox.TLS.model
    attr = tls.attributes.data

    this.el.parentNode.setAttribute("data-cols", attr)



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
      title: "NOTHING FOUND",
      message: message,
      extra_html: """
        <div class="message-button" rel="add-source">
          Add source
        </div>
      """,
      extra_classes: "nothing-here"
    )

    this.$el.append(message_html)



  add_loading_message: () ->
    return if this.$el.find(".message.loading").length

    $loading = $("<div class=\"message loading\" />")
    $loading.append("<span>loading tracks</span>")
    $loading.appendTo(this.$el)

    _.delay(=>
      this.$el.find(".message.loading").addClass("visible")
    , 250)



  #
  #  Statusses
  #
  is_in_queue_mode: () ->
    @mode is "queue"


  requires_playlist_layout: () ->
    (typeof OngakuRyoho.RecordBox.Filter.model.get("playlist")) is "number"
