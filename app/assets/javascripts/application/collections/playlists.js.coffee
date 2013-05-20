class OngakuRyoho.Classes.Collections.Playlists extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Playlist,
  url: "/api/playlists/",


  fetch: (options={}) ->
    options.reset = true
    Backbone.Collection.prototype.fetch.call(this, options)


  get_user_playlists: () ->
    this.filter (playlist) -> not playlist.get("special")


  get_special_playlists: () ->
    this.filter (playlist) -> playlist.get("special")
