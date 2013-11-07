class OngakuRyoho.Classes.Views.DropZones extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "pointerdragenter .queue" : @group.machine.queue_pointerdragenter
    "pointerdragleave .queue" : @group.machine.queue_pointerdragleave
    "pointerdrop .queue"      : @group.machine.queue_pointerdrop



  #
  #  Initialize
  #
  initialize: () ->
    super("DropZones")

    # this element
    Helpers.set_view_element(this, ".mod-drop-zones")

    # other elements
    this.$queue = this.$el.children(".queue")
