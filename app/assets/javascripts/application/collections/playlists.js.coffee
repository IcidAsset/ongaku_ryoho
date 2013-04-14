class OngakuRyoho.Classes.Collections.Playlists extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Playlist,
  url: "/data/playlists/",


  get_user_playlists: () ->
    this.filter (playlist) -> not playlist.get("special")


  get_special_playlists: () ->
    this.filter (playlist) -> playlist.get("special")
