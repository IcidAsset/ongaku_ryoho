class OngakuRyoho.Classes.Models.TLS extends Backbone.Model

  defaults:
    data: "data--default"
    group: "group--default"



  initialize: () ->
    this.on("change", (e) -> OngakuRyoho.People.ViewStateManager.save_state_in_local_storage())

    ###
      TODO:
      - on data change -> change filter sort_by accordingly
      - add checkboxes to menu
    ###
