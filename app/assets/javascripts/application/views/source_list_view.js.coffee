class OngakuRyoho.Classes.Views.SourceList extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click td.availability input" : "availability_checkbox_change"



  #
  #  Initialize
  #
  initialize: () ->
    super()

    # template
    @template = Helpers.get_template("source-list")

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



  #
  #  Events
  #
  availability_checkbox_change: (e) =>
    $checkbox = $(e.currentTarget)
    rel = $checkbox.closest("tr").attr("rel")
    model = OngakuRyoho.SourceManager.collection.get(parseInt(rel, 10))

    console.log model
