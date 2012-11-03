class OngakuRyoho.Classes.Views.Playlist.Track extends Backbone.View

  tagName: "li"
  className: "track"



  #
  #  Initialize
  #
  initialize: () ->
    @template = Handlebars.compile($("#track_template").html())



  #
  #  Render
  #
  render: () ->
    model_attr = @model.toJSON()

    # content
    this.$el.html(@template(model_attr))
    this.$el.attr("rel", @model.id)

    # extra classes
    this.$el.addClass("unavailable") if model_attr.unavailable

    # chain
    return this
