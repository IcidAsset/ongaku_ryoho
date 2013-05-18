class OngakuRyoho.Classes.Machinery.RecordBox.Navigation

  #
  #  Switches
  #
  toggle_queue: (e) =>
    vsm = OngakuRyoho.People.ViewStateManager
    if vsm.get_queue_status() is off then vsm.set_queue_status(on)
    else vsm.set_queue_status(off)



  #
  #  Track list header
  #
  sort_key_column_click_handler: (e) ->
    filter = OngakuRyoho.RecordBox.Filter.model

    current_sort_direction = filter.get("sort_direction")
    current_sort_key = filter.get("sort_by")
    selected_sort_key = e.currentTarget.getAttribute("data-sort-key")

    attributes = {
      sort_by: selected_sort_key,
      sort_direction: "asc"
    }

    if selected_sort_key is current_sort_key and current_sort_direction is "asc"
      attributes.sort_direction = "desc"

    filter.set(attributes)


  add_active_class_to_selected_sort_by_column: () ->
    sort_key = OngakuRyoho.RecordBox.Filter.model.get("sort_by")
    sort_direction = OngakuRyoho.RecordBox.Filter.model.get("sort_direction")

    $tlh = @group.view.$track_list_header
    $tlh.children().removeClass("active reverse")

    $column = $tlh.children("[data-sort-key=\"#{sort_key}\"]")
    $column.addClass("active")
    $column.addClass("reverse") if sort_direction is "desc"
