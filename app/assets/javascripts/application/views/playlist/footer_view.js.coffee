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
    @parent_group = OngakuRyoho.Playlist
    @group = @parent_group.Footer
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.Playlist.Footer
    @group.machine.group = @group
    @group.machine.parent_group = @parent_group

    # this element
    this.$el = $("#playlist").children("footer")



  #
  #  Set contents
  #
  set_contents: (html) =>
    this.$el.find(".intestines").html(html)
