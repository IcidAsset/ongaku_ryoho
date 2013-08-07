class OngakuRyoho.Classes.Machinery.RecordBox.PlaylistMenu

  playlist_click_handler: (e) =>
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(
      e.currentTarget.getAttribute("data-playlist-cid")
    )

    OngakuRyoho.RecordBox.Filter.model.enable_playlist(playlist)



  add_active_class_to_selected_playlist: () ->
    cid = OngakuRyoho.RecordBox.Filter.model.get("playlist_cid")
    selector = ".playlists .playlist"

    @group.view.$el.find(selector).removeClass("selected")
    @group.view.$el.find(selector).filter("[data-playlist-cid='#{cid}']").addClass("selected") if cid
