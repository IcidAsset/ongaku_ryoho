class OngakuRyoho.Classes.Views.SourceManager.SourceList extends Backbone.View

  className: "mod-source-list flexible"



  events: ->
    "click .light" : @machine.light_click_handler



  initialize: () ->
    @machine = new OngakuRyoho.Classes.Machinery.SourceManager.SourceList
    @machine.view = this

    # templates
    @template = Helpers.get_template("source-list")

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
    source_template = Helpers.get_template("source")

    # add sources
    OngakuRyoho.SourceManager.collection.each((source) ->
      source_attributes = source.toJSON()
      source_attributes.type_text = source.type_instance.type_text()
      source_attributes.label = source.type_instance.label()
      source_attributes.type_server = (source_attributes.type is "Server")
      source_attributes.type_s3bucket = (source_attributes.type is "S3Bucket")
      source_attributes.type_dropbox = (source_attributes.type is "DropboxAccount")

      source_el = document.createElement("div")
      source_el.classList.add("source")
      source_el.classList.add("available") if source_attributes.available
      source_el.classList.add("activated") if source_attributes.activated
      source_el.setAttribute("rel", source_attributes.id)
      source_el.innerHTML = source_template(source_attributes)

      fragment.appendChild(source_el)
    )

    # replace
    unless this.rendered_before
      this.el.innerHTML = @template()

    # append sources
    s = this.el.querySelector(".sources")

    if s
      s.innerHTML = ""
    else
      this.el.innerHTML = @template()
      s = this.el.querySelector(".sources")

    if fragment.childNodes.length is 0
      this.add_nothing_here_message(s.parentNode)
    else
      s.appendChild(fragment)

    # state
    this.rendered_before = true

    # chain
    this



  #
  #  Messages, info, etc.
  #
  add_nothing_here_message: (el) ->
    el.innerHTML = """
      <div class="message">
        No sources added yet
      </div>
    """
