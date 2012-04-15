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
      'setup_search', 'search_input_change', 'search',
      'show_current_track', 'set_footer_contents'
    );
    
    this.$search = this.$el.find('.navigation .search input');
    
    // setup views
    this.track_list_view = new OngakuRyoho.Views.TrackListView({ el: this.$el.find('.tracks-wrapper') });
    this.setup_search();
    
    // get content
    Tracks.fetch();
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
    // mouse interactions
    this.$search.on('focus', helpers.mouse_interactions.focus)
                .on('blur', helpers.mouse_interactions.blur);
    
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
      track = Tracks.find(function(track) { return track.get('id') == current_track.sID });
      PlaylistView.track_list_view.add_playing_class_to_track( track );
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
