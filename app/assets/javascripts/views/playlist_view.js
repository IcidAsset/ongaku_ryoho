OngakuRyoho.Views.Playlist = Backbone.View.extend({
  
  events : {
    'click .navigation .sources .change' : 'show_source_manager'
  },
  
  
  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this, 'setup_search', 'set_footer_contents');
    
    this.$search = this.$el.find('.navigation .search input');
    
    // setup views
    this.track_list_view = new OngakuRyoho.Views.TrackListView({ el: this.$el.find('.tracks-wrapper') });
    this.setup_search();
    
    // get content
    Tracks.fetch();
  },
  
  
  /**************************************
   *  Source stuff
   */
  show_source_manager : function() {
    SourceManagerView.show();
  },
  
  
  /**************************************
   *  Search stuff
   */
  setup_search : function() {
    this.$search.bind('focus', helpers.mouse_interactions.focus)
                .bind('blur', helpers.mouse_interactions.blur);
  },
  
  
  /**************************************
   *  Set footer contents
   */
  set_footer_contents : function(html) {
    this.$el.find('footer .intestines').html(html);
  }
  
  
});
