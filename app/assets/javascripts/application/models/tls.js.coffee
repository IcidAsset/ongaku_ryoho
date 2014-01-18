class OngakuRyoho.Classes.Models.TLS extends Backbone.Model

  defaults:
    data: "default"
    group: "default"



  initialize: () ->
    this.on("change", this.change_handler)



  get_current_column_names: () ->
    switch this.get("data")
      when "default" then columns = ["title", "artist", "album"]
      when "location" then columns = ["location"]

    columns



  get_current_default_sortby_column: () ->
    switch this.get("data")
      when "default" then def = "artist"
      when "location" then def = "location"

    def



  change_handler: (e) =>
    sort_by = OngakuRyoho.RecordBox.Filter.model.get("sort_by")
    columns = this.get_current_column_names()

    unless _.contains(columns, sort_by)
      def = this.get_current_default_sortby_column()
      OngakuRyoho.RecordBox.Filter.model.set("sort_by", def)

    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()
