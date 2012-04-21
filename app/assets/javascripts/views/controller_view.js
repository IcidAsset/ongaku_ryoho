OngakuRyoho.Views.Controller = Backbone.View.extend({
  
  time_template :         _.template('<%= time %>'),
  now_playing_template :  _.template('<span><%= now_playing %></span>'),
  
  
  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this,
              'get_current_track', 'set_current_track_in_document_title',
              'render_time', 'render_now_playing',
              
              'setup_sound_manager',
              'set_volume', 'set_mute',
              'insert_track', 'sound_onplay',
              'play', 'pause', 'stop',
              
              'setup_controller_buttons',
              'button_playpause_click_handler',
              'button_previous_click_handler',
              'button_next_click_handler',
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
    this.model.on('change:volume', this.set_volume);
    this.model.on('change:mute', this.set_mute);
    
    this.shuffle_track_history = [];
    this.shuffle_track_history_index = 0;
    
    this.$now_playing  = this.$el.find('.now-playing');
    this.$progress_bar = this.$el.find('.progress-bar');
    
    this.render_time();
    this.render_now_playing();
    
    this.setup_sound_manager();
    this.setup_controller_buttons();
    this.setup_progress_bar();
  },
  
  
  /**************************************
   *  Current track
   */
  get_current_track : function() {
    var current_sound, track;
    
    // set
    current_sound = this.current_sound;
    
    // get
    if (current_sound) {
      track = Tracks.find(function(track) { return track.get('id') == current_sound.sID });
    }
    
    return track;
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
    if ((!duration || duration === 0) && this.current_sound) {
      duration = this.current_sound.durationEstimate;
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
   *  Sound manager
   */
  setup_sound_manager : function() {
    // ready state
    this.sound_manager = { ready: false };
    
    // sound manager settings
    soundManager.url = soundManagerFlashURL;
    soundManager.flashVersion = 9;
    soundManager.useFlashBlock = false;
    soundManager.preferFlash = false;
    soundManager.flashPollingInterval = 250;
    soundManager.html5PollingInterval = 250;
    soundManager.debugMode = false;
    
    // when sound manager is ready
    soundManager.onready(function() {
      ControllerView.sound_manager.ready = true;
    });
  },
  
  
  set_volume : function() {
    if (this.current_sound) {
      this.current_sound.setVolume( Controller.get('volume') );
    }
  },
  
  
  set_mute : function() {
    if (this.current_sound) {
      if (Controller.get('mute')) {
        this.current_sound.mute();
      } else {
        this.current_sound.unmute();
      }
    }
  },
  
  
  insert_track : function(track) {
    var track_attributes, this_controller_view;
    
    // destroy current track
    if (this.current_sound) {
      soundManager.destroySound(this.current_sound.sID);
    }
    
    // track attributes
    track_attributes = track.toJSON();
    
    // this controller view
    this_controller_view = this;
    
    // create sound
    var new_sound = soundManager.createSound({
      id:           track_attributes.id,
      url:          track_attributes.url,
      
      volume:       0,
      autoLoad:     true,
      autoPlay:     true,
      stream:       true,
      
      onfinish:     this_controller_view.sound_onfinish,
      onload:       this_controller_view.sound_onload,
      onplay:       this_controller_view.sound_onplay,
      whileloading: this_controller_view.sound_whileloading,
      whileplaying: this_controller_view.sound_whileplaying
    });
    
    // current track
    this.current_sound = new_sound;
    
    // volume
    this.set_mute();
    this.set_volume();
    
    // controller attributes
    var controller_attributes = {
      time:        0,
      duration:    0,
      
      artist:      track_attributes.artist,
      title:       track_attributes.title,
      album:       track_attributes.album,
      
      now_playing: track_attributes.artist + ' - <strong>' + track_attributes.title + '</strong>'
    };
    
    Controller.set(controller_attributes);
    
    // add playing class to track
    PlaylistView.track_list_view.add_playing_class_to_track( track );
    
    // document title
    this.set_current_track_in_document_title();
  },
  
  
  sound_onfinish : function() {
    var repeat;
    
    // set
    repeat = Controller.get('repeat');
    
    // action
    if (repeat) {
      PlaylistView.track_list_view.$el.find('.track.playing').trigger('dblclick');
    } else {
      ControllerView.button_next_click_handler();
    }
  },
  
  
  sound_onload : function() {
    Controller.set({ duration: this.duration });
  },
  
  
  sound_onplay : function() {
    this.set_mute();
    this.set_volume();
  },
  
  
  sound_whileloading : function() {
    var percent_loaded = ((this.bytesLoaded / this.bytesTotal) * 100) + '%';
    
    ControllerView.$progress_bar
      .children('.progress.loader')
      .css('width', percent_loaded);
  },
  
  
  sound_whileplaying : function() {
    Controller.set({ time: this.position });
  },
  
  
  play : function() {
    var track_sound, track, $track;
    
    // set
    track_sound = this.current_sound;
    
    // if track set, resume or play
    if (track_sound) {
      if (Controller.get('mute')) {
        soundManager.mute(track_sound.sID);
      }
      
      if (track_sound.paused) {
        soundManager.resume(track_sound.sID);
      
      } else {
        soundManager.play(track_sound.sID);
      
      }
      
      this.set_current_track_in_document_title();
      
      return;
    }
    
    // if not ...
    var shuffle, $tracks;
    
    shuffle = Controller.get('shuffle');
    $tracks = PlaylistView.track_list_view.$el.find('.track');
    
    if (shuffle) {
      $track = $( _.shuffle($tracks)[0] );
    } else {
      $track = $tracks.first();
    }
    
    track = Tracks.getByCid( $track.attr('rel') );
    
    if (shuffle) {
      this.shuffle_track_history.push(
        Tracks.getByCid( $track.attr('rel') ).get('id')
      );
    }
    
    // insert track
    this.insert_track( track );
  },
  
  
  pause : function() {
    if (this.current_sound) {
      soundManager.pause(this.current_sound.sID);
      
      helpers.set_document_title(helpers.original_document_title);
    }
  },
  
  
  stop : function() {
    if (this.current_sound) {
      soundManager.stop(this.current_sound.sID);
      
      helpers.set_document_title(helpers.original_document_title);
    }
    
    Controller.set({ time: 0 });
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
      .on('click', this.button_previous_click_handler).end()
      .children('.btn.next')
      .on('click', this.button_next_click_handler);
    
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
    if (!this.sound_manager.ready) { return; }
    
    // set
    $button = $(e.currentTarget);
    state = (this.current_sound && !this.current_sound.paused) ? 'playing' : 'not playing';
    
    // action
    if (state == 'playing') {
      this.pause();
    
    } else {
      this.play();
    
    }
    
    // light
    if (state == 'playing') {
      $button.children('.light').removeClass('on');
    
    } else {
      $button.children('.light').addClass('on');
    
    }
  },
  
  
  button_previous_click_handler : function(e) {
    var shuffle, shuffle_th, track, $tracks, $track;
    
    // set
    shuffle = Controller.get('shuffle');
    shuffle_th = this.shuffle_track_history_index;
    
    $tracks = PlaylistView.track_list_view.$el.find('.track');
    
    // if there's no active track
    if (!this.current_sound) {
      return;
    
    // if so
    } else {
      if (shuffle) {
        if (shuffle_th > 0) {
          track = Tracks.find(function(t) {
            return t.get('id') === ControllerView.shuffle_track_history[shuffle_th - 1];
          });
        } else {
          return;
        }
        
        this.shuffle_track_history_index--;
        $track = $tracks.filter('[rel="' + track.cid + '"]');
        
      } else {
        $track = $tracks.filter('.playing').prev('.track');
        if (!$track.length) { $track = $tracks.last(); }
        
      }
      
    }
    
    $track.trigger('dblclick');
  },
  
  
  button_next_click_handler : function(e) {
    var shuffle, shuffle_th, track, $tracks, $track;
    
    // set
    shuffle = Controller.get('shuffle');
    shuffle_th = this.shuffle_track_history_index;
    
    $tracks = PlaylistView.track_list_view.$el.find('.track');
    
    // if there's no active track
    if (!this.current_sound) {
      if (shuffle) {
        $track = $( _.shuffle($tracks)[0] );
        
        this.shuffle_track_history.push(
          Tracks.getByCid( $track.attr('rel') ).get('id')
        );
        
      } else {
        $track = $tracks.first();
        
      }
    
    // if so
    } else {
      if (shuffle) {
        if (shuffle_th < this.shuffle_track_history.length - 1) {
          track = Tracks.find(function(t) {
            return t.get('id') === ControllerView.shuffle_track_history[shuffle_th + 1];
          });
          
        } else {
          track = _.shuffle(Tracks.reject(function(t) {
            return _.include(ControllerView.shuffle_track_history, t.get('id'));
          }))[0];
          
          this.shuffle_track_history.push( track.get('id') );
          
        }
        
        this.shuffle_track_history_index++;
        $track = $tracks.filter('[rel="' + track.cid + '"]');
        
      } else {
        $track = $tracks.filter('.playing').next('.track');
        if (!$track.length) { $track = $tracks.first(); }
        
      }
    
    }
    
    $track.trigger('dblclick');
  },
  
  
  switch_shuffle_click_handler : function(e) {
    var $switch, state;
    
    // set
    $switch = $(e.currentTarget);
    state = Controller.get('shuffle');
    
    // switch
    Controller.set('shuffle', !state);
    
    // light
    if (state) {
      $switch.children('.light').removeClass('on');
    
    } else {
      $switch.children('.light').addClass('on');
    
    }
  },
  
  
  switch_repeat_click_handler : function(e) {
    var $switch, state;
    
    // set
    $switch = $(e.currentTarget);
    state = Controller.get('repeat');
    
    // switch
    Controller.set('repeat', !state);
    
    // light
    if (state) {
      $switch.children('.light').removeClass('on');
    
    } else {
      $switch.children('.light').addClass('on');
    
    }
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
    
    // rotate
    helpers.css.rotate($t, angle);
    
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
    var $light, state;
    
    // set
    $light = $(e.currentTarget).children('.light');
    state = Controller.get('mute');
    
    // light
    if (state) {
      Controller.set('mute', false);
      $light.addClass('on');
    
    } else {
      Controller.set('mute', true);
      $light.removeClass('on');
    
    }
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
    if (!this.current_sound) { return; }
    
    // set
    percent = (e.pageX - this.$progress_bar.offset().left) / this.$progress_bar.width();
    
    // seek
    this.current_sound.setPosition( this.current_sound.duration * percent );
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
