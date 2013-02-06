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
    this.$el.html(@template(this.model.toJSON()))

    # add cid
    this.$el.attr("rel", @model.cid)

    # loading or error?
    if @model.get("loading")
      this.$el.addClass("loading").append("<div></div>")

    else if @model.get("error")
      this.$el.addClass("error")

    # chain
    return this
