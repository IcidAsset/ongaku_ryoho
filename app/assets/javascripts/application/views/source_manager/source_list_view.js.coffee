class OngakuRyoho.Classes.Views.SourceManager.SourceList extends Backbone.View

  className: "mod-source-list flexible"



  events: ->
    "click .light" : @machine.light_click_handler



  initialize: () ->
    @machine = new OngakuRyoho.Classes.Machinery.SourceManager.SourceList
    @machine.view = this

    # templates
    @template = Helpers.get_template("source-list")
    @source_template = Helpers.get_template("source")

    # collection events
    this.listenTo(OngakuRyoho.SourceManager.collection, "reset", this.render)
    this.listenTo(OngakuRyoho.SourceManager.collection, "add", this.render)
    this.listenTo(OngakuRyoho.SourceManager.collection, "remove", this.render)



  after_append: () ->
    @machine.setup_new_tooltip_instance()



  remove: () ->
    @machine.self_destruct_current_tooltip_instance()
    Backbone.View.prototype.remove.apply(this, arguments)



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
