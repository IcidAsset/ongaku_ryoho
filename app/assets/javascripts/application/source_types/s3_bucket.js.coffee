class OngakuRyoho.Classes.SourceTypes.S3Bucket

  type_text: () ->
    "S3 BUCKET"



  label: () ->
    this.s3bucket.get("name")



  is_available: () ->
    true



  update_tracks: (file_list) =>
    true



  insert_track_hook: (track) =>
    promise = new RSVP.Promise()
    source = OngakuRyoho.SourceManager.collection.get(track.get("source_id"))
    data = { track_location: encodeURIComponent(track.get("location")), host: source.get("s3_host") }
    signature_expire_date = track.get("signature_expire_date")

    # do nothing if the signature is still valid
    if signature_expire_date and (new Date(signature_expire_date * 1000) > (new Date))
      promise.resolve()

    # otherwise request a new signature
    else
      $.get("/api/sources/#{this.s3bucket.id}/s3_signed_url", data, (response) ->
        response = JSON.parse(response)

        track.set({
          url: response.signed_url,
          signature_expire_date: response.expire_date
        })

        promise.resolve()
      )

    # return
    promise



  track_url_to_src: (url, location) ->
    url
