OngakuRyoho.Views.Playlist = Backbone.View.extend({

  events : {
    'click .navigation .show-source-manager' : 'show_source_manager',
    'click .navigation .show-current-track' : 'show_current_track',
    'click .navigation .theater-mode' : 'theater_mode_button_click_handler',
    'click .navigation .check-sources' : 'check_sources_button_click_handler'
  },


  /**************************************
   *  Initialize
   */
  initialize : function() {
    var after_track_fetch;
    
    _.bindAll(this,
      'setup_search', 'search_input_change',
      'search', 'show_current_track', 'set_footer_contents'
    );

    this.$search = this.$el.find('.navigation .search input');

    // tracklist view
    this.track_list_view = new OngakuRyoho.Views.TrackList(
      { el: this.$el.find('.tracks-wrapper') }
    );

    // search
    this.setup_search();
    
    // after fetching tracks
    after_track_fetch = function() {
      SourceManagerView.check_sources();
    };

    // get content
    $.when(Sources.fetch())
     .then(function() {
       Tracks.fetch({ success: after_track_fetch });
     });
  },


  /**************************************
   *  Source manager
   */
  show_source_manager : function() {
    SourceManagerView.show();
  },


  /**************************************
   *  Search
   */
  setup_search : function() {
    // labelify
    this.$search.labelify();

    // change
    this.$search.on('change', this.search_input_change);
  },


  search_input_change : function(e) {
    var $t, value;

    // set
    $t = $(e.currentTarget);
    value = $t.val();

    // search
    this.search(value);
  },


  search : function(query) {
    this.track_list_view.collection.filter = query;

    // fetch tracks
    $.when(Tracks.fetch())
     .done(this.search_success);
  },


  search_success : function() {
    var current_track, track;

    // set
    current_track = ControllerView.current_track;

    // add playing class
    if (current_track) {
      PlaylistView.track_list_view.add_playing_class_to_track( current_track );
    }
  },


  /**************************************
  *  A bit of everything
  */
  show_current_track : function() {
    var $current_track;

    // set
    $current_track = this.track_list_view.$el.find('.track.playing');

    // scroll to current track
    if ($current_track.length && PlaylistView.track_list_view.has_scrollbar()) {
      this.track_list_view.$el.scrollbar('scrollto', $current_track.position().top);
    }
  },

  theater_mode_button_click_handler : function(e) {
    var state;

    // state
    state = $(e.currentTarget).hasClass('on') ? 'off' : 'on';

    // enable / disable
    helpers.set_theater_mode(state);
  },

  check_sources_button_click_handler : function(e) {
    SourceManagerView.check_sources();
  },


  /**************************************
   *  Set footer contents
   */
  set_footer_contents : function(html) {
    this.$el.find('footer .intestines').html(html);
  }


});
