class OngakuRyoho.Classes.Views.Message extends Backbone.View

  className: "message"



  #
  #  Initialize
  #
  initialize: () ->
    @template = Helpers.get_template("message")



  #
  #  Render
  #
  render: () ->
    this.el.innerHTML = @template(this.model.toJSON())

    # add cid
    this.el.setAttribute("rel", @model.cid)

    # loading or error?
    if @model.get("loading")
      this.el.classList.add("loading")
      this.el.appendChild(document.createElement("div"))

    else if @model.get("error")
      this.el.classList.add("error")

    # chain
    this
