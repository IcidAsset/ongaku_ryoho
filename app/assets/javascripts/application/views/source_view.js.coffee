class OngakuRyoho.Classes.Views.Source extends Backbone.View

  #
  #  Initialize
  #
  initialize: () =>
    @template = Handlebars.compile($("#source_template").html())



  #
  #  Render
  #
  render: () =>
    this.$el.html(@template(@model.toJSON()))

    # add class when available
    this.$el.addClass("available") if @model.get("available")

    # chain
    return this
