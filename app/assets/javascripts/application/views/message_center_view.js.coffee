class OngakuRyoho.Classes.Views.MessageCenter extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .message" : @group.machine.message_click_handler



  #
  #  Initialize
  #
  initialize: () ->
    super("MessageCenter")

    # this element
    Helpers.set_view_element(this, ".mod-message-center")

    # collection events
    this.listenTo(@group.collection, "add", this.add_message)
    this.listenTo(@group.collection, "remove", this.remove_message)



  #
  #  Add & remove
  #
  add_message: (message) =>
    # do nothing if extra-small resolution
    return if Helpers.responsive_state() is "extra-small"

    # make a view
    message.view = new OngakuRyoho.Classes.Views.Message({ model: message })

    # render message and add to dom
    $message = message.view.render().$el
    $message.appendTo(this.$el)

    # fade in message
    $message.css({ display: "block", opacity: 0 })
            .animate({ opacity: 1 }, { duration: 500 })

    # loading animation?
    if message.get("loading")
      Helpers.add_loading_animation(
        $message.children("div:first-child")[0]
      )



  remove_message: (message) =>
    view = message.view
    this.$el.find(".message[rel=\"#{message.cid}\"]")
        .animate({ opacity: 0 }, {
          duration: 500
          complete: -> view.remove() if view
        })
