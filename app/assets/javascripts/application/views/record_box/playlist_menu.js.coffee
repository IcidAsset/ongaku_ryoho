class OngakuRyoho.Classes.Views.RecordBox.PlaylistMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    @parent_group = OngakuRyoho.RecordBox
    @group = @parent_group.PlaylistMenu
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.RecordBox.PlaylistMenu
    @group.machine.group = @group
    @group.machine.parent_group = @parent_group

    # set elements
    $btn = OngakuRyoho.RecordBox.Navigation.view.$el.find(".select-wrap.playlist")

    # this element
    this.setElement($btn)

    # machinema
    @group.machine.setup_tooltip()
