class OngakuRyoho.Classes.Views.RecordBox.Track extends Backbone.View

  tagName: "li"
  className: "track"



  #
  #  Render
  #
  render: (template, position) ->
    model_attr = @model.toJSON()
    model_attr = _.extend(model_attr, { position: position }) if position

    # content
    this.el.innerHTML = template(model_attr)
    this.el.setAttribute("rel", @model.id) if @model.id

    # extra data and classes
    this.el.firstElementChild.setAttribute("data-favourite", "true") if model_attr.favourite_id
    this.el.firstElementChild.setAttribute("data-favourite-id", model_attr.favourite_id) if model_attr.favourite_id
    this.el.classList.add("unavailable") unless model_attr.available

    # draggable
    this.el.setAttribute("draggable", "true")

    # chain
    return this
