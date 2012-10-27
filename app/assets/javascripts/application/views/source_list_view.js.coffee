class OngakuRyoho.Classes.Views.SourceList extends Backbone.View

  #
  #  Initialize
  #
  initialize: () =>
    OngakuRyoho.SourceManager.collection.on("reset", this.render)



  #
  #  Render
  #
  render: () =>
    html = "<form><div class=\"source-list\"><ol>"

    # sources html
    OngakuRyoho.SourceManager.collection.each((source) ->
      source_view = new OngakuRyoho.Classes.Views.Source({ model: source })
      html = html + source_view.render().el.innerHTML
    , this)

    # ending html
    html = html + "</ol></div></form>"

    # set html
    this.$el.html(html)

    # chain
    return this
