class OngakuRyoho.Classes.Views.RecordBox.PlaylistMenu extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .playlist" : @group.machine.playlist_click_handler
    "click .add-playlist .add-button" : @group.machine.add_button_click_handler



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
    this.input_element = this.$el.find(".add-playlist input")

    # collection events
    this.listenTo(OngakuRyoho.RecordBox.Playlists.collection, "reset", this.render_playlists)

    # render
    this.render_playlists()



  #
  #  Visibility
  #
  show: () ->
    this.el.classList.add("visible")
    this.trigger_element.classList.add("active")

  hide: () ->
    this.el.classList.remove("visible")
    this.trigger_element.classList.remove("active")

  toggle: () ->
    this.el.classList.toggle("visible")
    this.trigger_element.classList.toggle("active")



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
        el.innerHTML = "<span class=\"icon\">&#57349;</span>" + playlist.get("name")
        fragment.appendChild(el)
      )

    playlists_container = this.el.querySelector(".playlists")
    playlists_container.innerHTML = ""
    playlists_container.appendChild(fragment)

    this.group.machine.add_active_class_to_selected_playlist()
