class OngakuRyoho.Classes.Views.TrackList extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "dblclick .track"          : @machine.play_track
    "click .track .favourite"  : @machine.track_rating_star_click



  #
  #  Initialize
  #
  initialize: () =>
    super()

    # related collection
    @collection = ℰ.Tracks

    # render
    @collection.on("reset", this.render)

    # fetch events
    @collection.on("fetching", @machine.fetching)
    @collection.on("fetched", @machine.fetched)

    # track list (window) resize
    $(window).on("resize", @machine.resize)
             .trigger("resize")



  #
  #  Render
  #
  render: () =>
    html = "<ol class=\"tracks\">"

    # sources html
    @collection.each((track) =>
      track_view = new OngakuRyoho.Classes.Views.Track({ model: track })
      html = html + track_view.render().el.innerHTML
    )

    # ending html
    html = html + "</ol>"

    # set html
    this.$el.html(html)

    # trigger resize
    $(window).trigger("resize")

    # set footer contents
    if @collection.length is 0
      message = ""

    else
      page_info = @collection.page_info()

      word = {
        pages: (if page_info.pages is 1 then "page" else "pages")
        tracks: (if page_info.total is 1 then "track" else "tracks")
      }

      message =  "#{page_info.total} #{word.tracks} found &mdash;
                  page #{page_info.page} / #{page_info.pages}"

    ℰ.PlaylistView.set_footer_contents(message)

    # chain
    return this
