OngakuRyoho.Views.TrackList = Backbone.View.extend({

  events : {
    'dblclick .track' : 'play_track',
    'click .track .favourite' : 'track_rating_star_click'
  },


  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this,
      'render', 'resize', 'fetching', 'fetched',
      'add_playing_class_to_track'
    );

    this.collection = Tracks;
    this.collection.on('reset', this.render);
    this.collection.on('fetching', this.fetching);
    this.collection.on('fetched', this.fetched);

    // track list (window) resize
    $(window).on('resize', this.resize)
             .trigger('resize');
  },


  /**************************************
   *  Render
   */
  render : function() {
    var html, message, page_info, word;
    
    // opening html
    html = '<ol class="tracks">';

    // sources html
    this.collection.each(function(track) {
      var track_view = new OngakuRyoho.Views.Track({ model: track });
      html += track_view.render().el.innerHTML;
    }, this);

    // ending html
    html += '</ol>';

    // set html
    this.$el.html(html);

    // odd
    this.$el.find('.track:odd').addClass('alt');

    // trigger resize
    $(window).trigger('resize');

    // set footer contents
    if (this.count_tracks() === 0) {
      message = "";

    } else {
      page_info = this.collection.page_info();
      
      word = {
        pages: (page_info.pages === 1 ? 'page' : 'pages'),
        tracks: (page_info.total === 1 ? 'track' : 'tracks')
      };

      message = page_info.total + ' ' + word.tracks +
                ' found &mdash; page ' + page_info.page +
                ' / ' + page_info.pages;

    }
    
    PlaylistView.set_footer_contents(message);

    // chain
    return this;
  },


  /**************************************
   *  Fetching and fetched events
   */
  fetching : function() {},


  fetched : function() {
    PlaylistView.check_page_navigation();
    
    if (this.count_tracks() === 0) {
      this.$el.html('<div class="nothing-here" />');

    } else {
      this.add_playing_class_to_track( SoundGuy.get_current_track() );
      PlaylistView.show_current_track();

    }
  },


  /**************************************
   *  Resize
   */
  resize : function(e) {
    var $list = this.$el.closest('.list'),

        new_height = (
           $(window).height() - 2 * 50 -
           $list.prev('.navigation').height() - 2 * 2 -
           $list.children('header').height() -
           $list.next('footer').height()
        ),

        $tw = this.$el;

    if ($tw) { $tw.height(new_height); }
  },
  
  
  /**************************************
   *  Add playing class to track
   */
  add_playing_class_to_track : function(track) {
    var $track;
    
    // check
    if (!track) { return; }
    
    // set elements
    $track = this.$el.find('.track[rel="' + track.cid + '"]');
    
    // set classes
    $track.parent().children('.track.playing').removeClass('playing');
    $track.addClass('playing');
  },


  /**************************************
   *  Play track
   */
  play_track : function(e) {
    var track, $t, $playpause_button_light;
    
    // set
    $t = $(e.currentTarget);
    
    // check
    if (!SoundGuy.sound_manager.ready || $t.hasClass('unavailable')) { return; }

    // set
    track = Tracks.getByCid( $t.attr('rel') );

    // insert track
    SoundGuy.insert_track( track );
    
    // set elements
    $playpause_button_light = ControllerView.$el.find('.controls a .button.play-pause .light');
    
    // turn the play button light on
    $playpause_button_light.addClass('on');
  },


  /**************************************
   *  Count tracks
   */
  count_tracks : function() {
    return this.$el.find('.track').length;
  },
  
  
  /**************************************
   *  Track rating star click event
   */
  track_rating_star_click : function(e) {
    var title, artist, favourite, $t, $track;
    
    // set
    $t = $(e.currentTarget);
    $track = $t.closest('.track');
    
    title = $track.find('.title span').text();
    artist = $track.find('.artist span').text();
    
    // check
    if ($t.data('favourite')) {
      $t.attr('data-favourite', false);
      $t.data('favourite', false);
      
      var favourites = Favourites.where({
        track_title: title,
        track_artist: artist
      });
      
      _.each(favourites, function(f) {
        f.destroy();
      });
      
    } else {
      $t.attr('data-favourite', true);
      $t.data('favourite', true);
      
      Favourites.create({
        track_title: title,
        track_artist: artist
      });
      
    }
    
    // prevent default
    e.preventDefault();
    e.stopPropagation();
    return false;
  }


});
