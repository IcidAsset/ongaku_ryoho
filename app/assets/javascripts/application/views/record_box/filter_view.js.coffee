class OngakuRyoho.Classes.Views.RecordBox.Filter extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    super

    # set elements
    $btn = OngakuRyoho.RecordBox.Navigation.view.$el.find(".filter")

    # this element
    this.setElement($btn[0])
