class OngakuRyoho.Classes.Views.RecordBox.UserMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    @group = OngakuRyoho.RecordBox.UserMenu
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.RecordBox.UserMenu
    @group.machine.group = @group

    # set elements
    $btn = OngakuRyoho.RecordBox.Navigation.view.$el.find(".toggle-user-menu")

    # this element
    this.setElement($btn)

    # machinema
    @group.machine.setup_tooltip()
    @group.machine.check_theater_mode()
