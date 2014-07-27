class OngakuRyoho.Classes.Views.SourceManager.Source extends Backbone.View

  className: "source"


  initialize: () ->
    this.listenTo(this.model, "change:processing", this.render)


  render: () =>
    source_attributes = this.model.toJSON()
    source_attributes.type_text = this.model.type_instance.type_text()
    source_attributes.label = this.model.type_instance.label()
    source_attributes.type_server = (source_attributes.type is "Server")
    source_attributes.type_s3bucket = (source_attributes.type is "S3Bucket")
    source_attributes.type_dropbox = (source_attributes.type is "DropboxAccount")

    this.el.classList.add("available") if source_attributes.available
    this.el.classList.add("activated") if source_attributes.activated
    this.el.setAttribute("rel", source_attributes.id)
    this.el.innerHTML = @template(source_attributes)

    this
