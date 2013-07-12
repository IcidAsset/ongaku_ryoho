class OngakuRyoho.Classes.SourceTypes.Server

  is_available: () ->
    available = null

    $.ajax({
      async: false,
      type: "HEAD",
      success: (() -> available = true),
      error: (() -> available = false)
    })

    available



  update_tracks: (file_list) =>
    this.get_data_from_source(file_list)



  #
  #  Data from source
  #
  get_data_from_source: (file_list) ->
    promise = new RSVP.Promise()
    url = this.server.get("configuration")["location"]

    if file_list.length is 0
      $.ajax(
        type: "GET"
        url: url
        dataType: "text"
        success: (response) -> promise.resolve(response)
        error: () -> promise.resolve(false)
      )

    else
      $.ajax(
        type: "POST"
        url: "#{url}check"
        data: { file_list: JSON.stringify(file_list) }
        dataType: "text"
        success: (response) -> promise.resolve(response)
        error: () -> promise.resolve(false)
      )

    # return
    promise
