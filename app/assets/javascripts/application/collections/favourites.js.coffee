class OngakuRyoho.Classes.Collections.Favourites extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Favourite,
  url: "/data/favourites/",

  initialize: () ->
    this.fetch()

    # events
    this.on("destroy", this.destroy_handler)



  destroy_handler: (favourite) ->
    track_id = favourite.get("track_id")
    track = OngakuRyoho.RecordBox.Tracks.collection.get(track_id) if track_id
    OngakuRyoho.RecordBox.Tracks.collection.remove(track) if track
