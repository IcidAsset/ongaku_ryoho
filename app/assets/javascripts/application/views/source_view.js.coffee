class OngakuRyoho.Classes.Views.Source extends Backbone.View

  tagName: "tr"



  #
  #  Initialize
  #
  initialize: () ->
    @template = Handlebars.compile($("#source-template").html())



  #
  #  Render
  #
  render: () ->
    this.$el.html(@template(@model.toJSON()))
    this.$el.attr("rel", @model.id)

    # add class when available
    this.$el.addClass("available") if @model.get("available")

    # chain
    return this
