OngakuRyoho.Views.Playlist = Backbone.View.extend({
  
  events : {
    'click .navigation .sources .change' : 'show_source_manager',
    'click .navigation .show-current-track' : 'show_current_track'
  },
  
  
  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this, 'setup_search', 'show_current_track', 'set_footer_contents');
    
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
    this.$search.bind('focus', helpers.mouse_interactions.focus)
                .bind('blur', helpers.mouse_interactions.blur);
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
