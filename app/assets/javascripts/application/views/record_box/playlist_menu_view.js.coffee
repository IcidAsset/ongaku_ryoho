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
    this.$input = this.$el.find(".add-playlist input[type=\"text\"]")

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

    if OngakuRyoho.RecordBox.Playlists.collection.models.length is 0
      # TODO
    else
      OngakuRyoho.RecordBox.Playlists.collection.each((playlist) ->
        el = document.createElement("div")
        el.classList.add("playlist")
        el.setAttribute("data-playlist-cid", playlist.cid)
        el.innerHTML = """
          <span class=\"icon\">&#57349;</span>#{playlist.get('name')}
          <div class="tooltip-data">
            <div class="group first">
              <a rel="remove">Remove</a>
            </div>
          </div>
          """
        fragment.appendChild(el)
      )

    playlists_container = this.el.querySelector(".playlists")
    playlists_container.innerHTML = ""
    playlists_container.appendChild(fragment)

    this.group.machine.add_active_class_to_selected_playlist()
