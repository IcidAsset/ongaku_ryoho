class OngakuRyoho.Classes.Views.RecordBox.UserMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    super("UserMenu")

    # this element
    el = OngakuRyoho.RecordBox.Navigation.view.el.querySelector(".toggle-user-menu")
    this.setElement(el)

    # machinema
    @group.machine.setup_tooltip()
    @group.machine.check_theater_mode()
