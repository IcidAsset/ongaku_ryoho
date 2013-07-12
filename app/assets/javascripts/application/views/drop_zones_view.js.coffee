class OngakuRyoho.Classes.Views.DropZones extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "dragenter .queue"    : @group.machine.queue_dragenter
    "dragleave .queue"    : @group.machine.queue_dragleave
    "dragover .queue"     : @group.machine.queue_dragover
    "drop .queue"         : @group.machine.queue_drop



  #
  #  Initialize
  #
  initialize: () ->
    super("DropZones")

    # this element
    Helpers.set_view_element(this, ".mod-drop-zones")

    # other elements
    this.$queue = this.$el.children(".queue")
