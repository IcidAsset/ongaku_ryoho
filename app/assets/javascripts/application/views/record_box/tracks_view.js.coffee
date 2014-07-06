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
    # position column
    a = (typeof OngakuRyoho.RecordBox.Filter.model.get("playlist") is "number")
    b = (this.mode is "default")

    # list html
    [list_html, footer_contents] = this["render_#{@mode}_mode"]()

    # if there are no tracks
    if list_html.length is 0
      this.el.innerHTML = """
        <div class="background"></div>
      """

      this.el.scrollTop = 0
      this.add_nothing_here_message()

      OngakuRyoho.RecordBox.Footer.view.set_contents("")

    # and if there are
    else
      this.el.innerHTML = """
        <div class="background"></div>
        <ol class="tracks">#{list_html}</ol>
      """

      this.el.scrollTop = 0

      if a and b then this.el.parentNode.classList.add("with-position-column")
      else this.el.parentNode.classList.remove("with-position-column")

      OngakuRyoho.RecordBox.Footer.view.set_contents(footer_contents)

    # chain
    return this



  render_default_mode: () ->
    if this.requires_playlist_layout()
      this.render_playlist_layout()
    else
      this.render_default_layout()



  render_default_layout: () ->
    page_info = @group.collection.page_info()
    track_template = this.get_correct_track_template()
    last_group_by_value = null
    group = OngakuRyoho.RecordBox.TLS.model.get("group")
    should_group = OngakuRyoho.RecordBox.TLS.model.should_group()
    tracks_view = this
    html = ""

    # render tracks
    @group.collection.each((track) ->
      if should_group
        group_by_value = switch group
          when "directory"
            split = track.get("location").split("/")
            split[split.length - 2] || "Root"
          when "date"
            date = track.get("created_at")
            if date
              date = new Date(track.get("created_at"))
              date_month = [
                "January", "February", "March", "April", "May",
                "June", "July", "August", "September", "October",
                "November", "December"
              ][date.getMonth()]
              "#{date.getDate()} #{date_month} #{date.getFullYear()}"
            else
              ""
          else
            ""

        if group_by_value isnt last_group_by_value
          html = html + tracks_view.make_group_html(group_by_value)
          last_group_by_value = group_by_value

      html = html + tracks_view.make_track_html(track, track_template, [])
    )

    # set footer contents
    word_tracks = (if page_info.total is 1 then "track" else "tracks")
    message = "#{page_info.total} #{word_tracks} found &mdash; page #{page_info.page} / #{page_info.pages}"

    # return
    [html, message]



  render_playlist_layout: () ->
    page_info = @group.collection.page_info()
    track_template = this.get_correct_track_template()
    tracks_view = this
    html = ""

    # collect
    filter_playlist = OngakuRyoho.RecordBox.Filter.model.get("playlist")
    filter_desc = (OngakuRyoho.RecordBox.Filter.model.get("sort_direction") is "desc")
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(filter_playlist)
    tracks_with_position = playlist.get("tracks_with_position")

    # tracks
    _.each(tracks_with_position, (pt) ->
      track = OngakuRyoho.RecordBox.Tracks.collection.get(pt.track_id)
      html = html + tracks_view.make_track_html(track, track_template, [], pt) if track
    )

    # set footer contents
    word_tracks = (if tracks_with_position.length is 1 then "track" else "tracks")
    message = "#{tracks_with_position.length} #{word_tracks} found &mdash; page #{page_info.page} / #{page_info.pages}"

    # return
    [html, message]



  render_queue_mode: () ->
    queue = OngakuRyoho.Engines.Queue
    message = "Queue &mdash; The next #{queue.data.combined_next.length} items"
    track_template = this.get_correct_track_template()
    tracks_view = this
    html = ""

    # group
    html = html + this.make_group_html("Queue")

    # tracks
    _.each(queue.data.combined_next, (map) ->
      return unless map.track
      extra_classes = ["queue-item"]
      extra_classes.push("user-selected") if map.user

      html = html + tracks_view.make_track_html(map.track, track_template, extra_classes)
    )

    # return
    [html, message]



  #
  #  Track
  #
  make_track_html: (model, template, extra_classes, playlist_track) ->
    model_attr = model.toJSON()
    model_attr = _.extend(model_attr, { position: playlist_track.position }) if playlist_track

    # location
    if OngakuRyoho.RecordBox.Filter.model.get("playlist_isspecial")
      model_attr.location = model_attr.location.replace(/^([^\/]+\/)/, "")

    # content
    html = "<li class=\"track #{extra_classes.join(" ")}\">#{template(model_attr)}</li>"
    html = html.replace("<li", "<li rel=\"#{model.id}\"") if model.id

    # extra data and classes
    html = html.replace("<li", "<li draggable=\"1\"") if model_attr.available
    html = html.replace("<li", "<li data-playlist-track-id=\"#{playlist_track.id}\"") if playlist_track
    html = html.replace("class=\"track", "class=\"track unavailable") unless model_attr.available

    html



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



  make_group_html: (content) ->
    """
      <li class="group">
        <span>#{content}</span>
      <li>
    """



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

    color = if sources_collection.get_available_and_activated().length is 0
      "bright"
    else
      "default"

    message_html = @message_template(
      title: "NOTHING FOUND",
      message: message,
      extra_html: """
        <div class="message-button" rel="add-source" color="#{color}">
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
