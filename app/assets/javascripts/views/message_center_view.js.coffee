class OngakuRyoho.Views.MessageCenter extends Backbone.View
  
  #
  #  Events
  #
  events:
    "click .message" : "message_click_handler"



  #
  #  Initialize
  #
  initialize: () =>
    @collection = Messages
    @collection.on("add", this.add_message)
    @collection.on("remove", this.remove_message)



  #
  #  Add & remove
  #
  add_message: (message) =>
    view = new OngakuRyoho.Views.Message({ model: message })
    
    # append html
    this.$el.append(view.render().el.innerHTML)
    
    # the $message
    $message = this.$el.find(".message:last")
    
    # fade in message
    $message.fadeIn(500)
    
    # loading animation?
    helpers.add_loading_animation($message.children("div")) if message.get("loading")



  remove_message: (message) =>
    this.$el
      .find(".message[rel=\"#{message.cid}\"]")
      .stop(true).fadeOut 500, () -> $(this).remove()



  #
  #  Mouse event handlers
  #
  message_click_handler: (e) =>
    $t = $(e.currentTarget)
    
    # check
    return if $t.hasClass("loading")
    
    # set
    cid = $t.attr("rel")
    message = Messages.find (m) -> m.cid is cid
     
    # remove message
    Messages.remove(message)
