class OngakuRyoho.Classes.Collections.Favourites extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Favourite,
  url: "/data/favourites/",

  initialize: () ->
    this.on("destroy", this.destroy_handler)



  destroy_handler: (favourite) ->
    Tracks = OngakuRyoho.RecordBox.Tracks

    if Tracks.collection.favourites is true
      track_id = favourite.get("track_id")
      track = Tracks.collection.get(track_id) if track_id
      Tracks.collection.remove(track) if track
