class OngakuRyoho.Views.Message extends Backbone.View
  
  #
  #  Initialize
  #
  initialize: () =>
    @template = _.template($("#message_template").html())



  #
  #  Render
  #
  render: () =>
    this.$el.html(this.template( this.model.toJSON() ))
    
    # jquery object
    $message = this.$el.children(".message").last()
    
    # add cid
    $message.attr("rel", @model.cid)
    
    # loading or error?
    if @model.get("loading")
      $message.addClass("loading").append("<div></div>")
      
    else if this.model.get("error")
      $message.addClass("error")

    # chain
    return this
