class OngakuRyoho.Classes.Views.RecordBox.PlaylistMenu extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "pointerdragenter .playlist"      : @group.machine.playlist_pointerdragenter
    "pointerdragleave .playlist"      : @group.machine.playlist_pointerdragleave
    "pointerdrop .playlist"           : @group.machine.playlist_pointerdrop

    "click .playlist"                 : @group.machine.playlist_click_handler
    "keydown .playlist .name"         : @group.machine.playlist_name_keydown_handler
    "blur .playlist .name"            : @group.machine.playlist_name_blur_handler
    "submit .add-playlist"            : @group.machine.add_playlist_submit_handler
    "keydown .add-playlist input"     : @group.machine.add_playlist_input_keydown_handler



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
    this.$el.find("input").removeAttr("disabled")
    this.el.classList.add("visible")
    this.trigger_element.classList.add("active")



  hide: () ->
    this.el.classList.remove("visible")
    this.trigger_element.classList.remove("active")
    this.group.machine.tooltip.hide_and_remove_current_tooltip()
    this.$el.find("input").attr("disabled", "disabled")



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
    playlists = OngakuRyoho.RecordBox.Playlists.collection.models

    # if there are no playlists
    if playlists.length is 0
      el = document.createElement("div")
      el.className = "is-empty"
      el.innerHTML = "<span>No playlists found</span>"
      fragment.appendChild(el)

    # and if there are
    else
      p1 = []
      p2 = []

      playlists = _.each(playlists, (p) ->
        if p.get("special")
          p2.push(p)
        else
          p1.push(p)
      )

      p1 = _.sortBy(p1, (p) -> p.get("name").toLowerCase())
      p2 = _.sortBy(p2, (p) -> p.get("name").toLowerCase())
      playlists = [].concat(p1, p2)

      _.each(playlists, (playlist) ->
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
