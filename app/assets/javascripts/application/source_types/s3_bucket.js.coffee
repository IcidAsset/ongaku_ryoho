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

    $.get("/api/sources/#{this.s3bucket.id}/s3_signature", data, (response) ->
      response = JSON.parse(response)
      original_url = track.get("original_url")

      unless original_url
        original_url = track.get("url")
        track.set("original_url", original_url)

      track.set("url", original_url + response.query_string)
      promise.resolve()
    )

    # return
    promise
