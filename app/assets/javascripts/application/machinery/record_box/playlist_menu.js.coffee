class OngakuRyoho.Classes.Machinery.RecordBox.PlaylistMenu

  playlist_click_handler: (e) =>
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(
      e.currentTarget.getAttribute("data-playlist-cid")
    )

    OngakuRyoho.RecordBox.Filter.model.enable_playlist(playlist)



  add_active_class_to_selected_playlist: () ->
    filter = OngakuRyoho.RecordBox.Filter.model
    selector = ".playlists .playlist"

    playlist_model = if filter.get("playlist_isspecial")
      OngakuRyoho.RecordBox.Playlists.collection.findWhere({
        name: filter.get("playlist_name")
      })
    else
      OngakuRyoho.RecordBox.Playlists.collection.get(
        filter.get("playlist")
      )

    cid = if playlist_model
      playlist_model.cid
    else
      false

    @group.view.$el.find(selector).removeClass("selected")
    @group.view.$el.find(selector).filter("[data-playlist-cid='#{cid}']").addClass("selected") if cid
