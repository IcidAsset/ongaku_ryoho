class OngakuRyoho.Classes.Machinery.RecordBox.Filter

  #
  #  Favourites
  #
  toggle_favourites: () =>
    @group.model.set("favourites", !@group.model.get("favourites"))


  disable_favourites: () =>
    @group.model.set("favourites", off)
