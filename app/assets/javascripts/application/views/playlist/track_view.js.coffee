class OngakuRyoho.Classes.Views.Playlist.Track extends Backbone.View

  #
  #  Initialize
  #
  initialize: () =>
    @template = Handlebars.compile($("#track_template").html())



  #
  #  Render
  #
  render: () =>
    this.$el.html(@template(@model.toJSON()))
    this.$el.children(".track").last().attr("rel", @model.id)

    # chain
    return this
