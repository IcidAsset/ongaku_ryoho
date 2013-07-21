class OngakuRyoho.Classes.SourceTypes.Server

  label: () ->
    config = this.server.get('configuration')

    if !config
      this.server.get("name")
    else if this.server.get("name").length > 0
      "#{this.server.get('name')} (#{location})"
    else
      location



  is_available: () ->
    available = null

    try
      $.ajax
        url: this.server.get("configuration")["location"]
        async: false
        type: "HEAD"
        success: () -> available = true
        error: () -> available = false
    catch error
      available = false

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
