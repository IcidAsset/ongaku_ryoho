class OngakuRyoho.Classes.Views.MessageCenter extends Backbone.View

  #
  #  Events
  #
  events:
    "click .message" : "message_click_handler"



  #
  #  Initialize
  #
  initialize: () =>
    @collection = 颪.Messages
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
    this.$el
      .find(".message[rel=\"#{message.cid}\"]")
      .fadeOut 500, () -> $(this).remove()



  #
  #  Mouse event handlers
  #
  message_click_handler: (e) =>
    $t = $(e.currentTarget)

    # check
    return if $t.hasClass("loading")

    # set
    cid = $t.attr("rel")
    message = 颪.Messages.find (m) -> m.cid is cid

    # remove message
    颪.Messages.remove(message)
