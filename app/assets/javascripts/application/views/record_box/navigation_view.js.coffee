class OngakuRyoho.Classes.Views.RecordBox.Navigation extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .toggle-queue" : @group.machine.toggle_queue



  #
  #  Initialize
  #
  initialize: () ->
    super

    # this element
    this.setElement($("#record-box").children(".navigation")[0])
