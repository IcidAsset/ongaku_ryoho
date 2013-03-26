class OngakuRyoho.Classes.Views.SourceManager extends Backbone.View

  #
  #  Events
  #
  events:
    "click header .close-button" : "hide"



  #
  #  Initialize
  #
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
  #  Render
  #
  render: (item="SourceList") ->
    view = new OngakuRyoho.Classes.Views[item]
    view.render().$el.appendTo(this.$el.find("section"))
