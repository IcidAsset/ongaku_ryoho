class OngakuRyoho.Classes.Views.MessageCenter extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .message" : @machine.message_click_handler



  #
  #  Initialize
  #
  initialize: () =>
    super()

    @collection = OngakuRyoho.Messages
    @collection.on("add", this.add_message)
    @collection.on("remove", this.remove_message)



  #
  #  Add & remove
  #
  add_message: (message) =>
    view = new OngakuRyoho.Classes.Views.Message({ model: message })

    # append html
    this.$el.append(view.render().el.innerHTML)

    # the $message
    $message = this.$el.find(".message").last()

    # fade in message
    $message.fadeIn(500)

    # loading animation?
    Helpers.add_loading_animation($message.children("div:first-child")[0]) if message.get("loading")



  remove_message: (message) =>
    this.$(".message[rel=\"#{message.cid}\"]")
        .fadeOut 500, () -> $(this).remove()
