class OngakuRyoho.Classes.Views.SourceManager.Modal extends Backbone.View

  events:
    "click [rel='close-modal']" : "hide"
    "click .toolbar [rel='refresh-sources']" : "toolbar_refresh_sources"



  initialize: () ->
    super

    # this element
    Helpers.set_view_element(this, ".mod-source-manager")

    # render
    this.render()



  #
  #  Show & Hide
  #
  show: () -> this.$el.show(0)
  hide: () -> this.$el.hide(0)



  #
  #  Rendering
  #
  render: (item="SourceList") ->
    view = new OngakuRyoho.Classes.Views.SourceManager[item]
    view.render().$el.appendTo(this.$el.find("section"))



  #
  #  Toolbar event handlers
  #
  toolbar_refresh_sources: (e) ->
    OngakuRyoho.SourceManager.collection.fetch()
    OngakuRyoho.RecordBox.Tracks.collection.fetch()
