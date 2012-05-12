OngakuRyoho.Views.Playlist = Backbone.View.extend({

  events : {
    'click .navigation .show-current-track' : 'show_current_track',
    'click .navigation .theater-mode' : 'theater_mode_button_click_handler',
    'click .navigation .check-sources' : 'check_sources_button_click_handler',
    'click .navigation .show-source-manager' : 'show_source_manager',
    'click .navigation .change-sort-direction' : 'change_sort_direction',
    
    'change .navigation .sort-by select' : 'sort_by_change_handler',
    'change .navigation .search input' : 'search_input_change',
    
    'click footer .page-nav .previous:not(.disabled)' : 'previous_page_button_click_handler',
    'click footer .page-nav .next:not(.disabled)' : 'next_page_button_click_handler'
  },


  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this,
      'show_source_manager', 'show_current_track',
      'setup_search', 'search_input_change', 'search', 'search_success',
      'theater_mode_button_click_handler',
      'check_sources_button_click_handler',
      'check_page_navigation',
      'previous_page_button_click_handler',
      'next_page_button_click_handler',
      'set_footer_contents'
    );

    // tracklist view
    this.track_list_view = new OngakuRyoho.Views.TrackList(
      { el: this.$el.find('.tracks-wrapper') }
    );

    // search
    this.$search = this.$el.find('.navigation .search input');
    this.setup_search();

    // get content
    $.when(Sources.fetch())
     .then(function() { Tracks.fetch({ success: SourceManagerView.check_sources }); });
  },


  /**************************************
   *  Source manager
   */
  show_source_manager : function() {
    SourceManagerView.show();
  },
  
  
  /**************************************
   *  Sort by
   */
  sort_by_change_handler : function(e) {
    var $t, value;
    
    // set
    $t = $(e.currentTarget);
    value = $t.children('option:selected').val();
    
    // search
    if (value) { this.sort_by(value); }
  },
  
  
  sort_by : function(query) {
    this.track_list_view.collection.sort_by = query;
    
    // fetch tracks
    Tracks.fetch();
  },
  
  
  change_sort_direction : function(e) {
    var current_direction, new_direction, $t;
    
    // set
    current_direction = this.track_list_view.collection.sort_direction;
    $t = $(e.currentTarget);
    
    // switch
    if (current_direction == 'asc') {
      new_direction = 'desc';
      $t.addClass('on');
      
    } else {
      new_direction = 'asc';
      $t.removeClass('on');
      
    }
    
    // change
    this.track_list_view.collection.sort_direction = new_direction;
    
    // reload tracks
    Tracks.fetch();
  },


  /**************************************
   *  Search
   */
  setup_search : function() {
    this.$search.labelify();
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
   *  Page navigation
   */
  check_page_navigation : function() {
    var page_info, $previous, $next;
    
    // set
    page_info = this.track_list_view.collection.page_info();
    $previous = this.$el.find('footer .page-nav .previous');
    $next = this.$el.find('footer .page-nav .next');
    
    // check
    if (!page_info.prev) { $previous.addClass('disabled'); }
    else { $previous.removeClass('disabled'); }
    
    if (!page_info.next) { $next.addClass('disabled'); }
    else { $next.removeClass('disabled'); }
  },
  
  previous_page_button_click_handler : function(e) {
    this.track_list_view.collection.previous_page();
  },
  
  next_page_button_click_handler : function(e) {
    this.track_list_view.collection.next_page();
  },


  /**************************************
   *  Set footer contents
   */
  set_footer_contents : function(html) {
    this.$el.find('footer .intestines').html(html);
  }


});
