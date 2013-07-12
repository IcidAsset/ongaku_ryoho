class OngakuRyoho.Classes.Views.RecordBox.UserMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    super("UserMenu")

    # this element
    menu_btn_element = OngakuRyoho.RecordBox.Navigation.view.$el.find(".toggle-user-menu")[0]
    this.setElement(menu_btn_element)

    # machinema
    @group.machine.setup_tooltip()
    @group.machine.check_theater_mode()
