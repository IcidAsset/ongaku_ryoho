class OngakuRyoho.Views.Visualizations extends Backbone.View
  
  #
  #  Initialize
  #
  initialize: () =>
    this.$peak_data = this.$el.children(".peak-data")



  #
  #  Visualize
  #
  visualize: (type, data) =>
    this[type](data)



  peak_data: (data) =>
    width_left = (data.left * 100) + "%"
    width_right = (data.right * 100) + "%"
    animation_duration = 50
    
    # animate
    this.$peak_data
      .children(".left")
      .animate({ width: width_left }, animation_duration)

    this.$peak_data
      .children(".right")
      .animate({ width: width_right }, animation_duration)
