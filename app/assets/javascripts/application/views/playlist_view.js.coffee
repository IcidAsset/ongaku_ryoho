class OngakuRyoho.Classes.Views.Playlist extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .navigation .change-sort-direction"         : @machine.change_sort_direction
    "click .navigation .theater-mode"                  : @machine.theater_mode_button_click_handler
    "click .navigation .show-favourites"               : @machine.show_favourites
    "click .navigation .show-source-manager"           : (() -> ℰ.SourceManagerView.show())

    "change .navigation .sort-by select"               : @machine.sort_by_change_handler
    "change .navigation .search input"                 : @machine.search_input_change

    "click footer .page-nav .previous:not(.disabled)"  : @machine.previous_page_button_click_handler
    "click footer .page-nav .next:not(.disabled)"      : @machine.next_page_button_click_handler



  #
  #  Initialize
  #
  initialize: () =>
    super()

    # tracklist view
    @track_list_view = new OngakuRyoho.Classes.Views.TrackList({ el: this.$(".tracks-wrapper") })

    # get content
    # ℰ.Sources.fetch({ success: ℰ.Sources.process_and_check_sources })

    # temporary
    ℰ.Tracks.fetch({ success: () ->
      track = ℰ.Tracks.models[Math.floor(Math.random() * (ℰ.Tracks.length - 1))]
      ℰ.SoundGuy.machine.play(track)
    })



  #
  #  Set footer contents
  #
  set_footer_contents: (html) =>
    this.$("footer .intestines").html(html)
