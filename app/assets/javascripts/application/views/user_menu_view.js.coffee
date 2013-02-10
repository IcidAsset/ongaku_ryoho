class OngakuRyoho.Classes.Views.UserMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    super()

    # set elements
    $btn = OngakuRyoho.RecordBox.Navigation.view.$el.find(".toggle-user-menu")

    # this element
    this.setElement($btn)

    # machinema
    @group.machine.setup_tooltip()
    @group.machine.check_theater_mode()
