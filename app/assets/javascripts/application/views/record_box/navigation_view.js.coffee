class OngakuRyoho.Classes.Views.RecordBox.Navigation extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .show-favourites"               : @group.machine.toggle_favourites
    "click .show-queue"                    : @group.machine.toggle_queue

    "change .search input"                 : @group.machine.search_input_change



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
