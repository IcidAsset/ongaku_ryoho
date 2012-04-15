OngakuRyoho.Views.SourceList = Backbone.View.extend({
  
  
  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this, 'render');
    
    this.collection = Sources;
    this.collection.on('reset', this.render);
  },
  
  
  /**************************************
   *  Render
   */
  render : function() {
    var html = '';
    
    // opening html
    html += '<form><div class="source-list"><ol>';
    
    // sources html
    this.collection.each(function(source) {
      var source_view = new OngakuRyoho.Views.Source({ model: source });
      html += source_view.render().el.innerHTML;
    }, this);
    
    // ending html
    html += '</ol></div></form>';
    
    // set html
    this.$el.html(html);
    
    // scrollbar
    this.$el
      .find('.source-list')
      .scrollbar({ arrows: false });
    
    // chain
    return this;
  }
  
  
});
