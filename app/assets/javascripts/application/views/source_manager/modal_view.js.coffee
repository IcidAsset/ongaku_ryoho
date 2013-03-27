class OngakuRyoho.Classes.Views.SourceManager.Modal extends Backbone.View

  events:
    "click header .close-button" : "hide"



  initialize: () ->
    super()

    # this element
    this.setElement(document.getElementById("source-manager"))

    # menu button
    this.$menu_button = OngakuRyoho.RecordBox.Navigation.
                        view.$el.find(".show-source-manager")

    # render
    this.render()



  #
  #  Show & Hide
  #
  show: () -> this.$menu_button.addClass("on"); this.$el.show(0)
  hide: () -> this.$menu_button.removeClass("on"); this.$el.hide(0)



  #
  #  Rendering
  #
  render: (item="SourceList") ->
    view = new OngakuRyoho.Classes.Views.SourceManager[item]
    view.render().$el.appendTo(this.$el.find("section"))
