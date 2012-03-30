OngakuRyoho.Views.Controller = Backbone.View.extend({
  
  time_template :         _.template('<%= time %>'),
  now_playing_template :  _.template('<span><%= now_playing %></span>'),
  
  
  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this,
              'render_time', 'render_now_playing',
              
              'setup_sound_manager', 'insert_track',
              'play', 'pause', 'stop',
              
              'setup_controller_buttons',
              'button_playpause_click_handler',
              'button_previous_click_handler',
              'button_next_click_handler',
              'switch_shuffle_click_handler',
              'switch_repeat_click_handler',
              
              'setup_progress_bar',
              'progress_bar_click_handler',
              
              'now_playing_marquee', 'now_playing_marquee_animation'
             );
    
    this.model = Controller;
    this.model.on('change:time', this.render_time);
    this.model.on('change:now_playing', this.render_now_playing);
    
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
   *  Render
   */
  render_time : function() {
    var time, duration, minutes, seconds, progress, time_html;
    
    // set
    time       = this.model.get('time');
    duration   = this.model.get('duration');
    
    // duration? really?
    if ((!duration || duration === 0) && this.current_track) {
      duration = this.current_track.durationEstimate;
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
    soundManager.preferFlash = true;
    soundManager.flashPollingInterval = 250;
    soundManager.html5PollingInterval = 250;
    
    // when sound manager is ready
    soundManager.onready(function() {
      ControllerView.sound_manager.ready = true;
      console.log('# Sound Manager is ready to make some noise!');
    });
  },
  
  
  insert_track : function(track) {
    var track_attributes, this_controller_view;
    
    // destroy current track
    if (this.current_track) {
      soundManager.destroySound(this.current_track.sID);
    }
    
    // track attributes
    track_attributes = track.toJSON();
    
    // this controller view
    this_controller_view = this;
    
    // create sound
    var new_sound = soundManager.createSound({
      id:           track_attributes.id,
      url:          track_attributes.url,
      
      volume:       50,
      autoLoad:     true,
      autoPlay:     true,
      stream:       true,
      
      onfinish:     this_controller_view.sound_onfinish,
      onload:       this_controller_view.sound_onload,
      whileloading: this_controller_view.sound_whileloading,
      whileplaying: this_controller_view.sound_whileplaying
    });
    
    // current track
    this.current_track = new_sound;
    
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
  },
  
  
  sound_onload : function() {
    Controller.set({ duration: this.duration });
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
  
  
  play : function() {
    var track_sound, track, $track;
    
    // set
    track_sound = this.current_track;
    
    // if track set, resume or play
    if (track_sound) {
      if (track_sound.paused) {
        soundManager.resume(track_sound.sID);
      
      } else {
        soundManager.play(track_sound.sID);
      
      }
      
      return;
    }
    
    // if not, play first track from playlist
    $track = PlaylistView.track_list_view.$el.find('.track:first');
    track = Tracks.getByCid( $track.attr('rel') );
    
    // insert track
    this.insert_track( track );
  },
  
  
  pause : function() {
    if (this.current_track) {
      soundManager.pause(this.current_track.sID);
    }
  },
  
  
  stop : function() {
    if (this.current_track) {
      soundManager.stop(this.current_track.sID);
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
    $buttons.filter('.play-pause').bind('click', this.button_playpause_click_handler);
    
    // previous and next
    $button_columns.filter('.previous-next')
      .children('.btn.previous')
      .bind('click', this.button_previous_click_handler).end()
      .children('.btn.next')
      .bind('click', this.button_next_click_handler);
    
    // shuffle
    $switches.filter('.shuffle').bind('click', this.switch_shuffle_click_handler);
    
    // repeat
    $switches.filter('.repeat').bind('click', this.switch_repeat_click_handler);
  },
  
  
  button_playpause_click_handler : function(e) {
    var $button, state;
    
    // check
    if (!this.sound_manager.ready) { return; }
    
    // set
    $button = $(e.currentTarget);
    state = (this.current_track && !this.current_track.paused) ? 'playing' : 'not playing';
    
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
    if (!this.current_track) {
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
    if (!this.current_track) {
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
  
  
  /**************************************
  *  Setup progress bar
  */
  setup_progress_bar : function() {
    // mouse events
    this.$progress_bar.parent().bind('click', this.progress_bar_click_handler);
  },
  
  
  progress_bar_click_handler : function(e) {
    var percent;
    
    // check
    if (!this.current_track) { return; }
    
    // set
    percent = (e.pageX - this.$progress_bar.offset().left) / this.$progress_bar.width();
    
    // seek
    this.current_track.setPosition( this.current_track.duration * percent );
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
