class OngakuRyoho.Classes.Models.Playlist extends Backbone.Model

  urlRoot:
    "/data/playlists/"

  defaults:
    name: ""
    tracks: []
    special: false


  tracks_attributes: ->
    _.map(@tracks, (track_id) ->
      track_id: track_id
    )


  toJSON: ->
    json = { playlist: _.clone(@attributes) }
    console.log(json)
    _.extend(json.playlist, { tracks_attributes: @tracks_attributes() })


  validate: (attrs, options) ->
    unless attrs.name.length > 1
      return "The name for your playlist should be at least two characters long"

    if OngakuRyoho.RecordBox.Playlists.collection.findWhere({ name: attrs.name })
      return "A playlist with the same name already exists"
