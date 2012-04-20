OngakuRyoho.Views.MessageCenter = Backbone.View.extend({

  events : {
    'click .message' : 'message_click_handler',
  },


  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this,
      'add_message', 'remove_message',
      'message_click_handler'
    );
    
    this.collection = Messages;
    this.collection.on('add', this.add_message);
    this.collection.on('remove', this.remove_message);
  },
  
  
  /**************************************
  *  Add & remove
  */
  add_message : function(message) {
    var view;
    
    // set
    view = new OngakuRyoho.Views.Message({ model: message });
    
    // append html
    this.$el.append(view.render().el.innerHTML);
    this.$el.find('.message:last').fadeIn(450);
    
    // loading animation?
    if (message.get('loading')) {
      helpers.add_loading_animation(this.$el.find('.message:last div'));
    }
  },
  
  
  remove_message : function(message) {
    this.$el
      .find('.message[rel="' + message.cid + '"]')
      .delay(500).fadeOut(450, function() { $(this).remove(); });
  },
  
  
  /**************************************
  *  Mouse event handlers
  */
  message_click_handler : function(e) {
    var $t, cid, message;
    
    // target
    $t = $(e.currentTarget);
    
    // check
    if ($t.hasClass('loading')) { return; }
    
    // set
    cid = $t.attr('rel');
    message = Messages.find(function(m) { return m.cid == cid });
     
    // remove message
    Messages.remove(message);
  }


});
