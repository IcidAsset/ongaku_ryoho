class OngakuRyoho.Classes.Views.SourceManager extends Backbone.View

  #
  #  Events
  #
  events:
    "click .background" : "hide"



  #
  #  Initialize
  #
  initialize: () =>
    super()

    $source_list_view = this.$(".window.main section")
    $add_section      = this.$(".window.add section")

    # menu button
    this.$menu_button = OngakuRyoho.PlaylistView.$el.find(".navigation .show-source-manager");

    # main section
    @source_list_view = new OngakuRyoho.Classes.Views.SourceList({ el: $source_list_view  })

    # add section
    @machine.setup_add_section($add_section)



  #
  #  Show & Hide
  #
  show: () -> this.$menu_button.addClass("on"); this.$el.show(0)
  hide: () -> this.$menu_button.removeClass("on"); this.$el.hide(0)
