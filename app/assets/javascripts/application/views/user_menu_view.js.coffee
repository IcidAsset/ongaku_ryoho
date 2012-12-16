class OngakuRyoho.Classes.Views.UserMenu extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click [rel=\"set-theater-mode\"]" : @group.machine.theater_mode_toggle
    "click [rel=\"source-manager\"]" : @group.machine.source_manager_toggle

    "mouseover" : @group.machine.clear_timeouts
    "mouseout" : @group.machine.set_timeout_for_hide



  #
  #  Initialize
  #
  initialize: () ->
    super()

    # this element
    this.setElement($("#user-menu"))

    # associated button
    this.$button = OngakuRyoho.RecordBox.Navigation.view.$el.find(".toggle-user-menu")

    # machinema
    @group.machine.check_theater_mode()



  #
  #  Visibility
  #
  show: () =>
    this.$el.removeClass("hidden")
    this.$button.addClass("on")
    this.group.machine.set_timeout_for_hide()
    this.group.machine.set_timeout_for_document_click()



  hide: () =>
    this.$el.addClass("hidden")
    this.$button.removeClass("on")
    this.group.machine.clear_timeouts()
    $(document).off("click", this.hide)
