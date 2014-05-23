class OngakuRyoho.Classes.Collections.Playlists extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Playlist,
  url: "/api/playlists/",


  fetch: (options={}) ->
    options.reset = true

    # get source ids
    sources = OngakuRyoho.SourceManager.collection.get_available_and_activated()
    sources = _.filter(sources, (s) -> s.get("configuration")["special_playlists"] is "1")
    source_ids = _.map(sources, (s) -> s.id).join(",")

    # check options
    options.data ?= {}

    # source_ids
    _.extend(options.data, { source_ids: source_ids })

    # super
    Backbone.Collection.prototype.fetch.call(this, options)



  get_user_playlists: () ->
    this.filter (playlist) -> not playlist.get("special")



  get_special_playlists: () ->
    this.filter (playlist) -> playlist.get("special")
