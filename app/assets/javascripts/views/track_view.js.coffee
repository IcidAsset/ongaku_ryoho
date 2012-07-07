class OngakuRyoho.Views.Track extends Backbone.View
  
  #
  #  Initialize
  #
  initialize: () =>
    @template = _.template($("#track_template").html())



  #
  #  Render
  #
  render: () =>
    this.$el.html(@template( @model.toJSON() ))
    this.$el.children(".track").last().attr("rel", @model.cid)
    
    # chain
    return this
