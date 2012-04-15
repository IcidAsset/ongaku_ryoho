var helpers = {
  
  
  /**************************************
  *  CSS Helpers
  */
  css : {
    
    rotate: function($el, degrees) {
      var css;
      
      css = {};
      
      css['-webkit-transform'] = 'rotate(' + degrees + 'deg)';
      css['-moz-transform'] = css['-webkit-transform'];
      css['-o-transform'] = css['-webkit-transform'];
      css['-ms-tranform'] = css['-webkit-transform'];
      
      $el.css(css);
    }
    
  }
  
  
};