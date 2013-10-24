class OngakuRyoho.Classes.Views.RecordBox.PlaylistMenu extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "dragenter .playlist"     : @group.machine.playlist_dragenter
    "dragleave .playlist"     : @group.machine.playlist_dragleave
    "dragover .playlist"      : @group.machine.playlist_dragover
    "drop .playlist"          : @group.machine.playlist_drop
    "click .playlist"         : @group.machine.playlist_click_handler
    "input .playlist .name"   : @group.machine.playlist_name_input_handler
    "blur .playlist .name"    : @group.machine.playlist_name_blur_handler
    "submit .add-playlist"    : @group.machine.add_playlist_submit_handler



  #
  #  Initialize
  #
  initialize: () ->
    super("PlaylistMenu")

    # this element
    this.setElement(
      document.querySelector(".mod-playlist-menu")
    )

    # elements
    this.trigger_element = OngakuRyoho.RecordBox.Filter.view.el.querySelector(".add-button.playlist")

    # collection events
    this.listenTo(OngakuRyoho.RecordBox.Playlists.collection, "reset", this.render_playlists)
    this.listenTo(OngakuRyoho.RecordBox.Playlists.collection, "add", this.render_playlists)
    this.listenTo(OngakuRyoho.RecordBox.Playlists.collection, "remove", this.render_playlists)

    # render
    this.render_playlists()
    this.group.machine.setup_tooltip();



  #
  #  Visibility
  #
  show: () ->
    this.el.classList.add("visible")
    this.trigger_element.classList.add("active")



  hide: () ->
    this.el.classList.remove("visible")
    this.trigger_element.classList.remove("active")
    this.group.machine.tooltip.hide_and_remove_current_tooltip()



  toggle: () ->
    if this.$el.hasClass("visible")
      this.hide()
    else
      this.show()



  #
  #  Rendering
  #
  render_playlists: () =>
    fragment = document.createDocumentFragment()

    # if there are no playlists
    if OngakuRyoho.RecordBox.Playlists.collection.models.length is 0
      ###
        TODO
      ###

    # and if there are
    else
      OngakuRyoho.RecordBox.Playlists.collection.each((playlist) ->
        el = document.createElement("div")
        el.className = "playlist"
        el.setAttribute("data-playlist-cid", playlist.cid)
        el.innerHTML = """
          <span class=\"icon\">#{if playlist.get("special") then "&#128193;" else "&#57349;"}</span>
          <span class=\"name\">#{playlist.get("name")}</span>
          """
        fragment.appendChild(el)
      )

    # add fragment to container
    playlists_container = this.el.querySelector(".playlists")
    playlists_container.innerHTML = ""
    playlists_container.appendChild(fragment)

    # mark selected playlist
    this.group.machine.add_active_class_to_selected_playlist()
