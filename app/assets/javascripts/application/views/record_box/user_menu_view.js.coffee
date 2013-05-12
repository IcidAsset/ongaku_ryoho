class OngakuRyoho.Classes.Views.RecordBox.UserMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    super

    # set elements
    $btn = OngakuRyoho.RecordBox.Navigation.view.$el.find(".toggle-user-menu")

    # this element
    this.setElement($btn[0])

    # machinema
    @group.machine.setup_tooltip()
    @group.machine.check_theater_mode()
