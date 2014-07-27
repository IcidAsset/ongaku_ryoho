class OngakuRyoho.Classes.Views.SourceManager.SourceList extends Backbone.View

  className: "mod-source-list flexible"



  events: ->
    "click .light" : @machine.light_click_handler



  initialize: () ->
    @machine = new OngakuRyoho.Classes.Machinery.SourceManager.SourceList
    @machine.view = this

    # templates
    @template = Helpers.get_template("source-list")

    # child views
    @child_views = []

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

    # remove old views
    _.each(@child_views, (v) -> v.remove())
    @child_views.length = 0

    # add sources
    OngakuRyoho.SourceManager.collection.each((source) =>
      view = new OngakuRyoho.Classes.Views.SourceManager.Source({ model: source })
      view.template = source_template
      fragment.appendChild(view.render().el)
      @child_views.push(view)
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
