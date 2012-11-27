class OngakuRyoho.Classes.Views.Playlist.Navigation extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .show-favourites"               : @group.machine.toggle_favourites
    "click .show-queue"                    : @group.machine.toggle_queue

    "change .search input"                 : @group.machine.search_input_change



  #
  #  Initialize
  #
  initialize: () ->
    @parent_group = OngakuRyoho.Playlist
    @group = @parent_group.Navigation
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.Playlist.Navigation
    @group.machine.group = @group
    @group.machine.parent_group = @parent_group

    # this element
    this.setElement($("#playlist").children(".navigation")[0])
