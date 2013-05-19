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
    this.on("change", this.change_handler)


  change_handler: () ->
    return unless OngakuRyoho.People.ViewStateManager.state.ready
    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()
