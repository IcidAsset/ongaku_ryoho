OngakuRyoho.Views.Visualizations = Backbone.View.extend({


  /**************************************
   *  Initialize
   */
  initialize : function() {
    _.bindAll(this,
      'visualize', 'peak_data'
    );
    
    this.$peak_data = this.$el.children('.peak-data');
  },
  
  
  /**************************************
   *  Visualize
   */
  visualize : function(type, data) {
    this[type](data);
  },
  
  
  peak_data : function(data) {
    var width_left, width_right, animation_duration;
    
    // set
    width_left = (data.left * 100) + '%';
    width_right = (data.right * 100) + '%';
    animation_duration = 50;
    
    // animate
    this.$peak_data
      .children('.left')
      .animate({ width: width_left }, animation_duration).end()
      .children('.right')
      .animate({ width: width_right }, animation_duration);
  }


});
