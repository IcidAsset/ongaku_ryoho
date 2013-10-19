class OngakuRyoho.Classes.SourceTypes.S3Bucket

  label: () ->
    this.s3bucket.get("name")



  is_available: () ->
    true



  update_tracks: (file_list) =>
    true



  insert_track_hook: (track) =>
    promise = new RSVP.Promise()
    data = { track_location: encodeURIComponent(track.get("location")) }
    signature_expire_date = track.get("signature_expire_date")

    # do nothing if the signature is still valid
    if signature_expire_date and (new Date(signature_expire_date * 1000) > (new Date))
      promise.resolve()

    # otherwise request a new signature
    else
      $.get("/api/sources/#{this.s3bucket.id}/s3_signature", data, (response) ->
        response = JSON.parse(response)
        original_url = track.get("original_url")

        unless original_url
          original_url = track.get("url")
          track.set("original_url", original_url)

        track.set({
          url: original_url + response.query_string,
          signature_expire_date: response.expire_date
        })

        promise.resolve()
      )

    # return
    promise
