OngakuRyoho.Views.Playlist = Backbone.View.extend({

  events : {
    'click .navigation .sources .change' : 'show_source_manager',
    'click .navigation .show-current-track' : 'show_current_track'
  },


  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this,
      'load_tracks', 'setup_search', 'search_input_change',
      'search', 'show_current_track', 'set_footer_contents'
    );

    this.$search = this.$el.find('.navigation .search input');

    // setup views
    this.track_list_view = new OngakuRyoho.Views.TrackList({ el: this.$el.find('.tracks-wrapper') });
    this.setup_search();

    // get content
    Tracks.fetch();
  },


  /**************************************
   *  Tracks
   */
  load_tracks : function() {
    $.when(
      Tracks.fetch()

    ).then(function() {
      PlaylistView.track_list_view.add_playing_class_to_track( ControllerView.get_current_track() )
      PlaylistView.show_current_track();

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
    var data;

    // set
    data = { filter: query };

    // fetch tracks
    $.when(Tracks.fetch({ data: data }))
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
    if ($current_track.length) {
      this.track_list_view.$el.scrollbar('scrollto', $current_track.position().top);
    }
  },


  /**************************************
   *  Set footer contents
   */
  set_footer_contents : function(html) {
    this.$el.find('footer .intestines').html(html);
  }


});
