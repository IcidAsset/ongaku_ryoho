class OngakuRyoho.Classes.Models.Playlist extends Backbone.Model

  urlRoot:
    "/api/playlists/"

  defaults:
    name: ""
    track_ids: []
    special: false


  validate: (attrs, options) ->
    unique_name = true

    # don't validate if playlist already exists
    if attrs.id
      return no

    # check name length
    unless attrs.name.length > 1
      return "The name for your playlist should be at least two characters long"

    # check if name is unique
    unique_name = !_.any(_.map(OngakuRyoho.RecordBox.Playlists.collection.models, (playlist) ->
      return playlist.attributes.name.toLowerCase() is attrs.name.toLowerCase()
    ))

    unless unique_name
      return "A playlist with the same name already exists"
