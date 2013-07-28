class OngakuRyoho.Classes.Views.RecordBox.PlaylistMenu extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    super("PlaylistMenu")

    # this element
    module_element = document.querySelector(".mod-playlist-menu")
    this.setElement(module_element)

    # trigger button
    this.trigger_element = OngakuRyoho.RecordBox.Filter.view.el.querySelector(".add-button.playlist")

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
  render_playlists: () ->
    console.log(OngakuRyoho.RecordBox)
