class OngakuRyoho.Classes.Machinery.RecordBox.PlaylistMenu

  playlist_click_handler: (e) =>
    playlist = OngakuRyoho.RecordBox.Playlists.collection.get(
      e.currentTarget.getAttribute("data-playlist-id")
    )

    OngakuRyoho.RecordBox.Filter.model.enable_playlist(playlist)
