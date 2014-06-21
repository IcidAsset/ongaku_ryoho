class OngakuRyoho.Classes.SourceTypes.DropboxAccount

  type_text: () ->
    "DROPBOX"



  label: () ->
    this.dropboxaccount.get("name")



  is_available: () ->
    true



  update_tracks: (file_list) =>
    true



  insert_track_hook: (track) =>
    promise = new RSVP.Promise()
    source = OngakuRyoho.SourceManager.collection.get(track.get("source_id"))
    url_expire_date = track.get("url_expire_date")

    path = "/" + source.get("configuration")["directory"].replace(/(^\/+|\/+$)/g, "")
    path = path.replace(/^\/{2,}/, "/") + "/" + track.get("location")
    data = { track_location: encodeURIComponent(path) }

    # do nothing if the url is still valid
    if url_expire_date and (new Date(url_expire_date * 1000) > (new Date))
      promise.resolve()

    # otherwise request a new url
    else
      $.get("/api/sources/#{this.dropboxaccount.id}/dropbox_media_url", data, (response) ->
        response = JSON.parse(response)

        track.set({
          url: response.media_url,
          url_expire_date: response.expire_date
        })

        promise.resolve()
      )

    # return
    promise



  track_url_to_src: (url, location) ->
    url



  get_authorize_url: () ->
    promise = new RSVP.Promise()

    $.ajax({
      type: "GET",
      url: "/api/sources/dropbox_authorize_url",
      success: (response) ->
        promise.resolve(response)
      error: () ->
        promise.reject()
    })

    promise
