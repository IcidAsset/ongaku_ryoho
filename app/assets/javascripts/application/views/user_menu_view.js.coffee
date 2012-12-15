class OngakuRyoho.Classes.Views.UserMenu extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click [rel=\"set-theater-mode\"]" : @group.machine.theater_mode_toggle



  #
  #  Initialize
  #
  initialize: () ->
    super()

    # this element
    this.setElement($("#user-menu"))

    # machinema
    @group.machine.check_theater_mode()



  #
  #  Visibility
  #
  show: () =>
    this.$el.removeClass("hidden")


  hide: () =>
    this.$el.addClass("hidden")
