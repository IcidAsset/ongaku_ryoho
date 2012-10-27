class OngakuRyoho.Classes.Views.Playlist.Tracks extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "dblclick .track"          : @group.machine.track_dblclick
    "click .track .favourite"  : @group.machine.track_rating_star_click



  #
  #  Initialize
  #
  initialize: () =>
    @group = OngakuRyoho.Playlist.Tracks
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.Playlist.Tracks
    @group.machine.group = @group

    # render
    @group.collection
      .on("reset", this.render)

    # fetch events
    @group.collection
      .on("fetching", @group.machine.fetching)
      .on("fetched", @group.machine.fetched)

    # track list (window) resize
    $(window).on("resize", @group.machine.resize)
             .trigger("resize")



  #
  #  Render
  #
  render: () =>
    html = "<ol class=\"tracks\">"

    # sources html
    @group.collection.each((track) =>
      track_view = new OngakuRyoho.Classes.Views.Playlist.Track({ model: track })
      html = html + track_view.render().el.innerHTML
    )

    # ending html
    html = html + "</ol>"

    # set html
    this.$el.html(html)

    # trigger resize
    $(window).trigger("resize")

    # set footer contents
    if @group.collection.length is 0
      message = ""

    else
      page_info = @group.collection.page_info()

      word = {
        pages: (if page_info.pages is 1 then "page" else "pages")
        tracks: (if page_info.total is 1 then "track" else "tracks")
      }

      message =  "#{page_info.total} #{word.tracks} found &mdash;
                  page #{page_info.page} / #{page_info.pages}"

    OngakuRyoho.Playlist.Footer.view.set_contents(message)

    # chain
    return this
