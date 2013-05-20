class OngakuRyoho.Classes.Collections.Favourites extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Favourite,
  url: "/api/favourites/",


  initialize: () ->
    this.on("destroy", this.destroy_handler)


  #
  #  Destroy / remove favourite(s)
  #
  destroy_handler: (favourite) ->
    Tracks = OngakuRyoho.RecordBox.Tracks
    Filter = OngakuRyoho.RecordBox.Filter

    # remove track from its collection if favourites are enable
    if Filter.model.get("favourites") is true
      track_id = favourite.get("track_id")
      track = Tracks.collection.get(track_id) if track_id
      Tracks.collection.remove(track) if track


  remove_matching_favourites: (title, artist, album) ->
    favourites = this.where({
      title: title,
      artist: artist,
      album: album
    })

    # destroy each + nullify relation
    _.each favourites, (f) ->
      track_id = f.get("track_id")
      f.destroy()

      t = OngakuRyoho.RecordBox.Tracks.collection.get(track_id)
      t.set("favourite_id", null) if t
