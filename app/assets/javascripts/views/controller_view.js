OngakuRyoho.Views.Controller = Backbone.View.extend({
  
  time_template :         _.template('<%= time %>'),
  now_playing_template :  _.template('<span><%= now_playing %></span>'),
  
  
  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this,
              'set_current_track_in_document_title',
              'render_time', 'render_now_playing',
              
              'setup_controller_buttons',
              'button_playpause_click_handler',
              'switch_shuffle_click_handler',
              'switch_repeat_click_handler',
              'knob_volume_mousedown_handler',
              'document_mousemove_handler_for_volume_knob',
              'document_mouseup_handler_for_volume_knob',
              'knob_volume_doubleclick_handler',
              'switch_volume_click_handler',
              
              'setup_progress_bar',
              'progress_bar_click_handler',
              
              'now_playing_marquee', 'now_playing_marquee_animation'
             );
    
    this.model = Controller;
    this.model.on('change:time', this.render_time);
    this.model.on('change:now_playing', this.render_now_playing);
    this.model.on('change:shuffle', SoundGuy.set_shuffle);
    this.model.on('change:repeat', SoundGuy.set_repeat);
    this.model.on('change:volume', SoundGuy.set_volume);
    this.model.on('change:mute', SoundGuy.set_mute);

    this.$now_playing  = this.$el.find('.now-playing');
    this.$progress_bar = this.$el.find('.progress-bar');

    this.render_time();
    this.render_now_playing();
    
    this.setup_controller_buttons();
    this.setup_progress_bar();
  },
  
  
  /**************************************
   *  Set track info in document title
   */
  set_current_track_in_document_title : function() {
    var track_info;
    
    // set
    track_info = Controller.get('artist') + ' – ' + Controller.get('title');
    
    // set document title
    helpers.set_document_title('▶ ' + track_info);
  },
  
  
  /**************************************
   *  Render
   */
  render_time : function() {
    var time, duration, minutes, seconds, progress, time_html;
    
    // set
    time       = this.model.get('time');
    duration   = this.model.get('duration');
    
    // duration? really?
    if ((!duration || duration === 0) && SoundGuy.current_sound) {
      duration = SoundGuy.current_sound.durationEstimate;
    }
    
    // set
    minutes    = Math.floor( (time / 1000) / 60 );
    seconds    = Math.floor( (time / 1000) - (minutes * 60) );
    
    progress   = (time / duration) * 100;
    
    time_html  = (minutes.toString().length === 1 ? '0' + minutes : minutes) + ':' +
                 (seconds.toString().length === 1 ? '0' + seconds : seconds);
    
    // time
    this.$now_playing.children('.time').html(
      this.time_template({ time: time_html })
    );
    
    // progress bar
    this.$progress_bar
        .children('.progress.track')
        .css('width', progress + '%');
    
    // chain
    return this;
  },
  
  
  render_now_playing : function() {
    // stop current animation
    this.$now_playing.find('.what .marquee-wrapper').stop(true, true);
    
    // set content
    this.$now_playing.children('.what').html(
      this.now_playing_template({ now_playing: this.model.get('now_playing') })
    );
    
    // activate animation
    this.now_playing_marquee();
    
    // chain
    return this;
  },
  
  
  /**************************************
   *  Controller buttons
   */
  setup_controller_buttons : function() {
    var $controls, $buttons, $button_columns, $switches, $knobs;
    
    // set
    $controls        = this.$el.children('.controls');
    $buttons         = $controls.find('a .button');
    $button_columns  = $controls.find('a .button-column');
    $switches        = $controls.find('a .switch');
    $knobs           = $controls.find('a .knob');
    
    // play/pause button
    $buttons.filter('.play-pause').on('click', this.button_playpause_click_handler);
    
    // previous and next
    $button_columns.filter('.previous-next')
      .children('.btn.previous')
      .on('click', SoundGuy.select_previous_track).end()
      .children('.btn.next')
      .on('click', SoundGuy.select_next_track);
    
    // shuffle
    $switches.filter('.shuffle').on('click', this.switch_shuffle_click_handler);
    
    // repeat
    $switches.filter('.repeat').on('click', this.switch_repeat_click_handler);
    
    // volume
    $knobs.filter('.volume')
      .on('mousedown', this.knob_volume_mousedown_handler)
      .on('dblclick', this.knob_volume_doubleclick_handler);
    
    $switches.filter('.volume').on('click', this.switch_volume_click_handler);
  },
  
  
  button_playpause_click_handler : function(e) {
    var $button, state;
    
    // check
    if (!SoundGuy.sound_manager.ready) { return; }
    
    // set
    $button = $(e.currentTarget);
    state = (SoundGuy.current_sound && !SoundGuy.current_sound.paused) ? 'playing' : 'not playing';
    
    // action
    if (state == 'playing') {
      SoundGuy.pause_current_track();
    
    } else {
      SoundGuy.play_track();
    
    }
    
    // light
    if (state == 'playing') {
      $button.children('.light').removeClass('on');
    
    } else {
      $button.children('.light').addClass('on');
    
    }
  },
  
  
  switch_shuffle_click_handler : function(e) {
    Controller.set('shuffle', !Controller.get('shuffle'));
  },
  
  
  switch_repeat_click_handler : function(e) {
    Controller.set('repeat', !Controller.get('repeat'));
  },
  
  
  knob_volume_mousedown_handler : function(e) {
    $(e.currentTarget).off('mousedown', this.knob_volume_mousedown_handler);
    $(document).on('mousemove', this.document_mousemove_handler_for_volume_knob);
    $(document).on('mouseup', this.document_mouseup_handler_for_volume_knob);
  },
  
  
  document_mousemove_handler_for_volume_knob : function(e) {
    var knob_x, knob_y, mouse_x, mouse_y, distance,
        kx, ky, mx, my, angle, volume, $t;
    
    // set
    $t = $(e.currentTarget).find('.it div');
    knob_x = $t.offset().left + $t.width() / 2;
    knob_y = $t.offset().top + $t.height() / 2;
    mouse_x = e.pageX;
    mouse_y = e.pageY;
    
    mx = mouse_x - knob_x;
    my = mouse_y - knob_y
    kx = 0;
    ky = 0;
    
    distance = Math.sqrt( Math.pow(mx - kx, 2) + Math.pow(my - ky, 2) );
    if (distance < 15) { return; }
    
    angle = -(Math.atan2( kx - mx, ky - my ) * ( 180 / Math.PI ));
    
    if (angle > 135) { angle = 135; }
    else if (angle < -135) { angle = -135; }
    
    // set volume
    volume = 50 + (angle / 135) * 50;
    Controller.set('volume', volume);
  },
  
  
  document_mouseup_handler_for_volume_knob : function(e) {
    // unbind
    $(document).off('mousemove', this.document_mousemove_handler_for_volume_knob);
    $(document).off('mouseup', this.document_mouseup_handler_for_volume_knob);
    
    // rebind
    this.$el
      .find('.controls .knob.volume')
      .on('mousedown', this.knob_volume_mousedown_handler);
  },
  
  
  knob_volume_doubleclick_handler : function(e) {
    var $t;
    
    // set
    $t = $(e.currentTarget).find('.it div');
    
    // reset rotation
    helpers.css.rotate($t, 0);
    
    // set volume
    Controller.set('volume', 50)
  },
  
  
  switch_volume_click_handler : function(e) {
    Controller.set('mute', !Controller.get('mute'));
  },
  
  
  /**************************************
   *  Setup progress bar
   */
  setup_progress_bar : function() {
    // mouse events
    this.$progress_bar.parent().on('click', this.progress_bar_click_handler);
  },
  
  
  progress_bar_click_handler : function(e) {
    var percent;
    
    // check
    if (!SoundGuy.current_sound) { return; }
    
    // set
    percent = (e.pageX - this.$progress_bar.offset().left) / this.$progress_bar.width();
    
    // seek
    SoundGuy.current_sound.setPosition( SoundGuy.current_sound.duration * percent );
  },
  
  
  /**************************************
   *  Now playing marquee
   */
  now_playing_marquee : function() {
    var $what = this.$el.find('.now-playing .what'),
        $span = $what.children('span'),
        wrap_width = $what.width(),
        text_width = $span.width();
    
    // check
    if (text_width < wrap_width) { return; }
    
    // css stuff
    $what.css({ position: 'relative' });
    $span
      .wrap('<div class="marquee-wrapper"></div>')
      .css({ float: 'left', paddingRight: '65px' })
      .parent()
      .css({ overflow: 'hidden',
             position: 'absolute',
             width: '5000px'
      });
    
    $span.after($span.clone());
    
    // animate
    this.now_playing_marquee_animation($span.parent());
  },
  
  
  now_playing_marquee_animation : function($thing_that_scrolls) {
    // width of text, etc.
    var text_width = $thing_that_scrolls.children('span:first').outerWidth(),
        anim_speed = text_width * 39.5,
        wait_for   = 3000,
        
        controller_view = this;
    
    // animate
    $thing_that_scrolls.delay(wait_for).animate({ left: -text_width }, anim_speed, 'linear', function(e) {
      var $t = $(this);
      $t.css('left', 0);
      
      controller_view.now_playing_marquee_animation($t);
    });
  }
  
  
});
