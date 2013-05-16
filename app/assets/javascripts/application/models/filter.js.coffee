class OngakuRyoho.Classes.Models.Filter extends Backbone.Model

  defaults:
    playlist: off
    searches: []
    favourites: off
    page: 1
    per_page: 500
    sort_by: "artist"
    sort_direction: "asc"


  initialize: () ->
    this.on("change", this.fetch_tracks)


  fetch_tracks: () ->
    OngakuRyoho.RecordBox.Tracks.collection.fetch({ reset: true })
