class OngakuRyoho.Classes.Models.TLS extends Backbone.Model

  defaults:
    data: "default"
    group: "default"



  initialize: () ->
    this.on("change:data", this.data_change_handler)
    this.on("change:group", this.group_change_handler)



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



  data_change_handler: (e) =>
    sort_by = OngakuRyoho.RecordBox.Filter.model.get("sort_by")
    columns = this.get_current_column_names()

    # reset sort-by
    unless _.contains(columns, sort_by)
      def = this.get_current_default_sortby_column()
      OngakuRyoho.RecordBox.Filter.model.set("sort_by", def)
      resorted = true
    else
      resorted = false

    # tracks view / set list data attr
    OngakuRyoho.RecordBox.Tracks.view.set_list_data_attr()

    # render tracks if needed
    if !resorted and OngakuRyoho.People.ViewStateManager.state.ready
      OngakuRyoho.RecordBox.Tracks.view.render()

    # save state
    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()



  group_change_handler: (e) =>
    OngakuRyoho.RecordBox.Filter.model.set("group_by", this.get("group"))
