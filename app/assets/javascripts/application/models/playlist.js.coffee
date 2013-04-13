class OngakuRyoho.Classes.Models.Playlist extends Backbone.Model

  defaults:
    name: ""
    tracks: []

  tracks_attributes: ->
    _.map(@tracks, (track_id) ->
      track_id: track_id
    )

  toJSON: ->
    json = { playlist: _.clone(@attributes) }
    _.extend(json.playlist, { tracks_attributes: @tracks_attributes() })
