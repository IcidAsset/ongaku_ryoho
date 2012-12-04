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
    fav_id = model_attr.favourite_id

    # content
    this.$el.html(@template(model_attr))
    this.$el.attr("rel", @model.id)

    # extra data and classes
    this.$el.addClass("unavailable") unless model_attr.available
    this.$el.data("favourite-id", fav_id) if fav_id

    # draggable
    this.$el.attr("draggable", "true")

    # chain
    return this
