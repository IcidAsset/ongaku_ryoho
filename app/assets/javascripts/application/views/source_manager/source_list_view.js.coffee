class OngakuRyoho.Classes.Views.SourceManager.SourceList extends Backbone.View

  className: "mod-source-list"



  initialize: () ->
    super()

    # templates
    @template = Helpers.get_template("source-list")
    @source_template = Helpers.get_template("source")

    # collection events
    OngakuRyoho.SourceManager.collection.on("reset", this.render)


  destroy: () ->
    OngakuRyoho.SourceManager.collection.off("reset", this.render)
    this.remove()



  #
  #  Rendering
  #
  render: () =>
    fragment = document.createDocumentFragment()
    source_template = @source_template

    # add sources
    OngakuRyoho.SourceManager.collection.each((source) ->
      source_el = document.createElement("div")
      source_el.classList.add("source")
      source_el.innerHTML = source_template(source.toJSON())
      fragment.appendChild(source_el)
    )

    # replace
    this.el.innerHTML = @template()
    this.el.querySelector(".sources").appendChild(fragment)

    # chain
    return this
