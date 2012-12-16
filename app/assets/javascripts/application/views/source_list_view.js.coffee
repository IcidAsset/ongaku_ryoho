class OngakuRyoho.Classes.Views.SourceList extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    @template = Handlebars.compile($("#source-list-template").html())

    # collection events
    OngakuRyoho.SourceManager.collection.on("reset", this.render)



  #
  #  Render
  #
  render: () =>
    this.$el.html(@template())

    # cache
    $tbody = this.$el.find("tbody")

    # add sources
    OngakuRyoho.SourceManager.collection.each((source) ->
      source_view = new OngakuRyoho.Classes.Views.Source({ model: source })
      $tbody.append(source_view.render().$el)
    )

    # chain
    return this
