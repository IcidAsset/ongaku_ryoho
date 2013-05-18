class OngakuRyoho.Classes.Machinery.RecordBox.Filter

  constructor: () ->
    this.sort_by_change_handler()



  #
  #  Favourites
  #
  toggle_favourites: () =>
    @group.model.set("favourites", !@group.model.get("favourites"))


  disable_favourites: () =>
    @group.model.set("favourites", off)



  #
  #  Other model event handlers
  #
  fetch_tracks: () ->
    OngakuRyoho.RecordBox.Tracks.collection.fetch({ reset: true })


  sort_by_change_handler: (e) ->
    OngakuRyoho.RecordBox.Navigation.machine.add_active_class_to_selected_sort_by_column()
