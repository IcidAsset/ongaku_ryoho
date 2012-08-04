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
    $source_list_view = this.$el.find(".window.main section")
    $add_section      = this.$el.find(".window.add section")

    # main section
    @source_list_view = new OngakuRyoho.Classes.Views.SourceList({ el: $source_list_view  })

    # add section
    this.setup_add_section($add_section)



  #
  #  Setup add forms
  #
  setup_add_section: ($add_section) =>
    $select = $add_section.find(".select-wrapper select")
    $forms_wrapper = $add_section.find(".forms-wrapper")

    # when the "source selection" has changed
    $select.on("change", () ->
      $t    = $(this)
      klass = "." + $t.val()

      $forms.not(klass).hide(0)
      $forms.filter(klass).show(0)
    )

    # load forms
    $.get("/servers/new", (servers_form) ->
      $forms_wrapper.append(servers_form)
      $forms_wrapper.children("form").first().show(0)
    )



  #
  #  Show & Hide
  #
  show: () =>
    this.$el.show(0)



  hide: () =>
    this.$el.hide(0)
