class OngakuRyoho.Classes.Collections.Favourites extends Backbone.Collection

  model: OngakuRyoho.Classes.Models.Favourite,
  url: "/favourites/",

  initialize: () -> this.fetch()
