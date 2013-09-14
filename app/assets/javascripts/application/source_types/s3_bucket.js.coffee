class OngakuRyoho.Classes.SourceTypes.S3Bucket

  label: () ->
    this.s3bucket.get("name")



  is_available: () ->
    true



  update_tracks: (file_list) =>
    true
