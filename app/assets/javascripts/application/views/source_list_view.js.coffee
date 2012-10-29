class OngakuRyoho.Classes.Views.SourceList extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    @template = Handlebars.compile($("#source_list_template").html())

    # collection events
    OngakuRyoho.SourceManager.collection.on("reset", this.render)



  #
  #  Render
  #
  render: () =>
    this.$el.html(@template())

    # cache
    $list = this.$el.find(".source-list ol")

    # add sources
    OngakuRyoho.SourceManager.collection.each((source) ->
      source_view = new OngakuRyoho.Classes.Views.Source({ model: source })
      $list.append(source_view.render().$el)
    )

    # chain
    return this
