var helpers = {


  /**************************************
   *  Initialize
   */
  initialize_before : function() {
    this.original_document_title = document.title;

    // when the page loses focus, disable animations
    $(window).on('focus', helpers.enable_jquery_animations)
             .on('blur', helpers.disable_jquery_animations);
  },

  initialize_after : function() {
    // check theater mode
    this.check_theater_mode_cookie({ disable_animation: true });
  },


  /**************************************
   *  CSS Helpers
   */
  css : {

    rotate : function($el, degrees) {
      var css;

      css = {};

      css['-webkit-transform'] = 'rotate(' + degrees + 'deg)';
      css['-moz-transform'] = css['-webkit-transform'];
      css['-o-transform'] = css['-webkit-transform'];
      css['-ms-tranform'] = css['-webkit-transform'];

      $el.css(css);
    }

  },


  /**************************************
   *  Loading animation
   */
  add_loading_animation : function($target) {
    var opts = {
      lines: 6,
      length: 3,
      width: 1,
      radius: 3,
      rotate: 90,
      color: '#fff',
      speed: 1,
      trail: 60,
      shadow: false
    },

    spinner = new Spinner(opts).spin($target[0]);
    return spinner;
  },


  /**************************************
   *  Set document title
   */
  set_document_title : function(text, set_original_title) {
    if (set_original_title) { this.original_document_title = document.title }
    document.title = text;
  },


  /**************************************
   *  Enable / disable jQuery animations
   */
  enable_jquery_animations : function() {
    $.fx.off = false;
  },

  disable_jquery_animations : function() {
    $.fx.off = true;
  },


  /**************************************
   *  Enable / disable jQuery animations
   */
  set_theater_mode : function(state, options) {
    var animation_duration, $button, $color_overlay;

    // check options
    options = options || {};

    // set
    animation_duration = options.disable_animation ? 0 : 950;

    // set elements
    $button = PlaylistView.$el.find('.navigation .button.theater-mode');
    $color_overlay = $('#color-overlay');

    // go
    if (state == 'off') {
      $button.removeClass('on');
      $color_overlay.fadeOut(animation_duration);

    } else {
      $button.addClass('on');
      $color_overlay.fadeIn(animation_duration);

    }

    // save state in cookie
    $.cookie('theater_mode_state', state, { expires: 365, path: '/' });
  },

  check_theater_mode_cookie : function(options) {
    var cookie;

    // check options
    options = options || {};

    // set
    cookie = $.cookie('theater_mode_state');

    // check
    if (cookie && cookie == 'on') {
      helpers.set_theater_mode('on' ,options);
    }
  }


};