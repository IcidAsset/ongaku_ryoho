OngakuRyoho.Views.SourceView = Backbone.View.extend({
  
  
  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this, 'render');
    
    this.template = _.template($('#source_template').html());
  },
  
  
  /**************************************
   *  Render
   */
  render : function() {
    $(this.el).html(this.template( this.model.toJSON() ));
    
    var available = this.model.get('available');
    if (available) {
      $(this.el).addClass('available');
    }
    
    return this;
  }
  
  
});