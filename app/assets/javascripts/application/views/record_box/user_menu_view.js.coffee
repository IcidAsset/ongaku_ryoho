class OngakuRyoho.Classes.Views.RecordBox.UserMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    super

    # set elements
    btn_element = OngakuRyoho.RecordBox.Navigation.view.$el.find(".toggle-user-menu").get(0)

    # this element
    this.setElement(btn_element)

    # machinema
    @group.machine.setup_tooltip()
    @group.machine.check_theater_mode()
