var helpers = {
  
  
  /**************************************
   *  Mouse interactions
   */
  mouse_interactions : {
    
    focus : function(e) {
      var t = e.target;
      if (t.value === t.defaultValue) { $(this).val(''); }
    },
    
    blur : function(e) {
      var t = e.target;
      
      if (t.value === t.defaultValue || t.value === '') {
        $(this).removeClass('dont');
        
      } else {
        $(this).addClass('dont');
      
      }
      
      if (t.value === '') { $(this).val(t.defaultValue); }
    }
    
  }
  
  
};