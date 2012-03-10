OngakuRyoho.Views.TrackListView = Backbone.View.extend({
  
  events : {
    'dblclick .track' : 'play_track'
  },
  
  
  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this, 'render', 'resize', 'activate_scrollbar');
    
    this.collection = Tracks;
    this.collection.bind('reset', this.render);
    
    // track list (window) resize
    $(window).bind('resize', this.resize)
             .trigger('resize');
  },
  
  
  /**************************************
   *  Render
   */
  render : function() {
    var html = '';
    
    // opening html
    html += '<ol class="tracks">';
    
    // sources html
    this.collection.each(function(track) {
      var track_view = new OngakuRyoho.Views.TrackView({ model: track });
      html += track_view.render().el.innerHTML;
    }, this);
    
    // ending html
    html += '</ol>';
    
    // set html
    this.$el.html(html);
    
    // odd
    this.$el.find('.track:odd').addClass('alt');
    
    // trigger resize for the scrollbar
    $(window).trigger('resize');
    
    // set footer contents
    var message = this.$el.find('.track').length + ' tracks found';
    PlaylistView.set_footer_contents(message);
    
    // chain
    return this;
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
    
    if ($tw) {
      
      // height
      $tw.height(new_height);
      
      // scrollbar
      if ($tw.find('ol.tracks').height() <= new_height) {
        $tw.scrollbar('unscrollbar');
      
      } else if ($tw.find('.scrollbar-pane').length === 0) {
        this.activate_scrollbar();
      
      } else {
        $tw.scrollbar('repaint');
      
      }
      
    }
  },
  
  
  /**************************************
   *  Activate scrollbar
   */
  activate_scrollbar : function() {
    this.el.scrollbar({ arrows: false });
  },
  
  
  /**************************************
   *  Play track
   */
  play_track : function(e) {
    var track, $track;
    
    // set
    $track  = $(e.currentTarget);
    track   = Tracks.getByCid( $track.attr('rel') ).toJSON();
    
    // insert track
    ControllerView.insert_track( track );
    
    // add playing class
    $track.parent().find('.track.playing').removeClass('playing');
    $track.addClass('playing');
  }
  
  
});
