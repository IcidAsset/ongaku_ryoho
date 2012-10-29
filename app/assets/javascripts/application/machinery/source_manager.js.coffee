class OngakuRyoho.Classes.Machinery.SourceManager

  #
  #  Setup add forms
  #
  setup_add_section: ($add_section) ->
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
