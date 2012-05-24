class OngakuRyoho.Collections.Favourites extends Backbone.Collection

  model: OngakuRyoho.Models.Favourite,
  url: "/favourites/",
  
  initialize: () -> this.fetch()
