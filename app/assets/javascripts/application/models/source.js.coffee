class OngakuRyoho.Classes.Models.Source extends Backbone.Model

  get_file_list: () ->
    promise = new RSVP.Promise()
    url = "#{this.url()}/file_list"

    # get file list from server
    $.get(url, (response) -> promise.resolve(response))

    # return
    promise



  #
  #  Processing
  #
  process: () ->
    promise = new RSVP.Promise()

    # each type has another method
    type = @attributes.type.toLowerCase()
    this["process_#{type}_type"]()

    # return
    promise



  process_server_type: (promise) ->
    this.get_file_list().then((file_list) ->
      console.log(file_list)
    )

    promise.resolve()
