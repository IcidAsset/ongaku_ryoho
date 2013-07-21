class OngakuRyoho.Classes.SourceTypes.Server

  label: () ->
    this.server.get("name")



  is_available: () ->
    available = null
    config = this.server.get("configuration")

    # if the ip addresses don't match
    if !config or (config.boundary isnt OngakuRyohoPreloadedData.user_ip)
      available = false

    # if they do match
    else
      try
        $.ajax
          url: this.server.get("configuration")["location"]
          async: false
          type: "HEAD"
          success: () -> available = true
          error: () -> available = false
      catch error
        available = false

    # return
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
