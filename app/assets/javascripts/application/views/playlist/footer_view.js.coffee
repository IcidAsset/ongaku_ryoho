class OngakuRyoho.Classes.Views.Playlist.Footer extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .page-nav .previous:not(.disabled)"  : @group.machine.previous_page_button_click_handler
    "click .page-nav .next:not(.disabled)"      : @group.machine.next_page_button_click_handler



  #
  #  Initialize
  #
  initialize: () =>
    @group = OngakuRyoho.Playlist.Footer
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.Playlist.Footer
    @group.machine.group = @group



  #
  #  Set contents
  #
  set_contents: (html) =>
    this.$el.find(".intestines").html(html)
