var helpers = {
  
  
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
  }
  
  
};