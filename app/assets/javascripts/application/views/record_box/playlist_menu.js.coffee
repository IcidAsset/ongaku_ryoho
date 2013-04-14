class OngakuRyoho.Classes.Views.RecordBox.PlaylistMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    @group = OngakuRyoho.RecordBox.PlaylistMenu
    @group.view = this
    @group.machine = new OngakuRyoho.Classes.Machinery.RecordBox.PlaylistMenu
    @group.machine.group = @group
    @group.playlists_collection = OngakuRyoho.RecordBox.Playlists.collection

    # set elements
    $btn = OngakuRyoho.RecordBox.Navigation.view.$el.find(".select-wrap.playlist")
    this.setElement($btn)

    # machinema
    @group.machine.setup_tooltip()

    # events
    @group.playlists_collection.on("reset", this.render)
    @group.playlists_collection.on("add", this.render)



  #
  #  Render
  #
  render: () =>
    items = {
      user_playlists: document.createDocumentFragment(),
      special_playlists: document.createDocumentFragment()
    }

    create_new_item = (playlist, type) ->
      a = document.createElement("a")
      a.setAttribute("rel", playlist.get("id"))
      a.innerHTML = playlist.get("name")
      items["#{type}_playlists"].appendChild(a)

    _.each(@group.playlists_collection.get_user_playlists(), (p) -> create_new_item(p, "user"))
    _.each(@group.playlists_collection.get_special_playlists(), (p) -> create_new_item(p, "special"))

    $el = this.$el.add($(".mod-playlist-menu"))
    $el.each ->
      $groups = $(this).find(".group[rel$='-playlists']")
      $groups.each ->
        this.innerHTML = ""
        this.appendChild( items[this.getAttribute("rel").replace("-", "_")] )
