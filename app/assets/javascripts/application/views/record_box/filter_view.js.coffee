class OngakuRyoho.Classes.Views.RecordBox.Filter extends Backbone.View

  #
  #  Events
  #
  # TODO: click .removeable-button.favourites -> disable_favourites
  events: () ->
    "click .add-button.favourites" : @group.machine.toggle_favourites



  #
  #  Initialize
  #
  initialize: () ->
    super

    # set elements
    $btn = OngakuRyoho.RecordBox.Navigation.view.$el.find(".filter")

    # this element
    this.setElement($btn[0])

    # model events
    @group.model.on("change", this.render)



  #
  #  Render
  #
  render: () =>
    # TODO: add removeable buttons here
