class OngakuRyoho.Classes.Views.SourceList extends Backbone.View

  className: "mod-source-list"



  #
  #  Initialize
  #
  initialize: () ->
    super()

    # templates
    @template = Helpers.get_template("source-list")
    @source_template = Helpers.get_template("source")

    # collection events
    OngakuRyoho.SourceManager.collection.on("reset", this.render)



  #
  #  Render
  #
  render: () =>
    fragment = document.createDocumentFragment()
    source_template = @source_template

    # add sources
    OngakuRyoho.SourceManager.collection.each((source) ->
      source_el = document.createElement("div")
      source_el.innerHTML = source_template(source.toJSON())
      fragment.appendChild(source_el)
    )

    # replace
    this.el.innerHTML = @template()
    this.el.querySelector(".scrollable").appendChild(fragment)

    # chain
    return this
