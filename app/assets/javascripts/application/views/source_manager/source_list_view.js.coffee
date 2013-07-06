class OngakuRyoho.Classes.Views.SourceManager.SourceList extends Backbone.View

  className: "mod-source-list flexible"



  events:
    "click .light" : "light_click_handler"



  initialize: () ->
    super

    # templates
    @template = Helpers.get_template("source-list")
    @source_template = Helpers.get_template("source")

    # collection events
    this.listenTo(OngakuRyoho.SourceManager.collection, "reset", this.render)
    this.listenTo(OngakuRyoho.SourceManager.collection, "add", this.render)



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
    if this.rendered_before
      this.el.querySelector(".sources").innerHTML = ""
    else
      this.el.innerHTML = @template()

    # append sources
    this.el.querySelector(".sources").appendChild(fragment)

    # state
    this.rendered_before = true

    # chain
    return this



  #
  #  Event handlers
  #
  light_click_handler: (e) =>
    id = $(e.currentTarget).closest(".source").attr("rel")
    model = OngakuRyoho.SourceManager.collection.get(id)
    model.save(
      { activated: !model.get("activated") },
      { success: () -> OngakuRyoho.RecordBox.Tracks.collection.fetch() }
    )

    # render list
    this.render()
