OngakuRyoho.Views.Message = Backbone.View.extend({


  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this, 'render');

    this.template = _.template($('#message_template').html());
  },


  /**************************************
   *  Render
   */
  render : function() {
    var $message;
    
    // html from template
    this.$el.html(this.template( this.model.toJSON() ));
    
    // jquery object
    $message = this.$el.children('.message:last');
    
    // add cid
    $message.attr('rel', this.model.cid);
    
    // loading animation?
    if (this.model.get('loading')) {
      $message.addClass('loading').append('<div></div>');
    }

    return this;
  }


});
