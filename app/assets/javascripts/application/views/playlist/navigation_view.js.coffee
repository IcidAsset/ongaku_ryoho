class OngakuRyoho.Classes.Views.Playlist.Navigation extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .change-sort-direction"         : @group.machine.change_sort_direction
    "click .theater-mode"                  : @group.machine.theater_mode_button_click_handler
    "click .show-favourites"               : @group.machine.show_favourites
    "click .show-source-manager"           : (() -> OngakuRyoho.SourceManager.view.show())

    "change .sort-by select"               : @group.machine.sort_by_change_handler
    "change .search input"                 : @group.machine.search_input_change



  #
  #  Initialize
  #
  initialize: () =>
    @parent_group = OngakuRyoho.Playlist
    @group = @parent_group.Navigation
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.Playlist.Navigation
    @group.machine.group = @group
    @group.machine.parent_group = @parent_group
