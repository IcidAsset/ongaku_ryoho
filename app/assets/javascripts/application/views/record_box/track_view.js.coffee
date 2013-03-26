class OngakuRyoho.Classes.Views.RecordBox.Track extends Backbone.View

  tagName: "li"
  className: "track"



  #
  #  Render
  #
  render: (template) ->
    model_attr = @model.toJSON()

    # content
    this.el.innerHTML = template(model_attr)
    this.el.setAttribute("rel", @model.id)

    # extra data and classes
    this.el.firstElementChild.setAttribute("data-favourite", "true") if model_attr.favourite_id
    this.el.classList.add("unavailable") unless model_attr.available

    # draggable
    this.el.setAttribute("draggable", "true")

    # chain
    return this
