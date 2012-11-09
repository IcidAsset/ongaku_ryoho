class OngakuRyoho.Classes.Views.Playlist.Tracks extends Backbone.View

  group_template: _.template("<li class=\"group\"><span><%= title %></span></li>")
  mode: "default"



  #
  #  Events
  #
  events: () ->
    "dblclick .track"          : @group.machine.track_dblclick
    "click .track .favourite"  : @group.machine.track_rating_star_click
    "dragstart .track"         : @group.machine.track_dragstart
    "dragend .track"           : @group.machine.track_dragend



  #
  #  Initialize
  #
  initialize: () ->
    @parent_group = OngakuRyoho.Playlist
    @group = @parent_group.Tracks
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.Playlist.Tracks
    @group.machine.group = @group
    @group.machine.parent_group = @parent_group

    # this element
    this.setElement($("#playlist").find(".tracks-wrapper")[0])

    # render
    @group.collection
      .on("reset", this.render)

    # fetch events
    @group.collection
      .on("fetching", @group.machine.fetching)
      .on("fetched", @group.machine.fetched)



  #
  #  Render
  #
  render: () =>
    $list = $("<ol class=\"tracks\"></ol>")

    # render
    this["render_#{this.mode}"]($list)

    # scroll to top
    this.el.scrollTop = 0

    # add list to main elements
    this.$el.empty()
    this.$el.append($list)

    # check
    if $list.children("li").length is 0
      this.$el.html("<div class=\"nothing-here\" />")
      OngakuRyoho.Playlist.Footer.view.set_contents("")

    # chain
    return this



  render_default: ($list) =>
    page_info = @group.collection.page_info()

    # tracks
    @group.collection.each((track) =>
      track_view = new OngakuRyoho.Classes.Views.Playlist.Track({ model: track })
      $list.append(track_view.render().el)
    )

    # set footer contents
    message = (() ->
      word_tracks = (if page_info.total is 1 then "track" else "tracks")
      "#{page_info.total} #{word_tracks} found &mdash;
      page #{page_info.page} / #{page_info.pages}"
    )()

    OngakuRyoho.Playlist.Footer.view.set_contents(message)



  render_queue: ($list) =>
    queue = OngakuRyoho.Engines.Queue
    message = "Queue &mdash; The next #{queue.data.combined_next.length} items"

    # group
    $list.append(@group_template({ title: "Queue" }))

    # tracks
    _.each(queue.data.combined_next, (map) =>
      track = @group.collection.get(map.id)
      return unless track

      track_view = new OngakuRyoho.Classes.Views.Playlist.Track({ model: track })
      track_view.$el.addClass("queue-item")
      track_view.$el.addClass("user-selected") if map.user

      $list.append(track_view.render().el)
    )

    # set foorter contents
    OngakuRyoho.Playlist.Footer.view.set_contents(message)
