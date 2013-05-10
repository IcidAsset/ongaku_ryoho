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
    @parent_group = OngakuRyoho.RecordBox
    @group = @parent_group.Navigation
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.RecordBox.Navigation
    @group.machine.group = @group
    @group.machine.parent_group = @parent_group

    # this element
    this.setElement($("#record-box").children(".navigation")[0])
