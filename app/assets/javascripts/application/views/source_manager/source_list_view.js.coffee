class OngakuRyoho.Classes.Views.SourceManager.SourceList extends Backbone.View

  className: "mod-source-list"



  events:
    "click .light" : "light_click_handler"



  initialize: () ->
    super

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
      source_attributes = source.toJSON()
      source_el = document.createElement("div")
      source_el.classList.add("source")
      source_el.classList.add("available") if source_attributes.available
      source_el.classList.add("activated") if source_attributes.activated
      source_el.setAttribute("rel", source_attributes.id)
      source_el.innerHTML = source_template(source_attributes)
      fragment.appendChild(source_el)
    )

    # replace
    this.el.innerHTML = @template()
    this.el.querySelector(".sources").appendChild(fragment)

    # chain
    return this



  #
  #  Event handlers
  #
  light_click_handler: (e) =>
    id = $(e.currentTarget).closest(".source").attr("rel")
    model = OngakuRyoho.SourceManager.collection.get(id)
    model.save({ activated: !model.get("activated") })
    this.render()
