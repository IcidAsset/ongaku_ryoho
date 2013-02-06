class OngakuRyoho.Classes.Views.Source extends Backbone.View

  tagName: "tr"



  #
  #  Initialize
  #
  initialize: () ->
    @template = Helpers.get_template("source")



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
