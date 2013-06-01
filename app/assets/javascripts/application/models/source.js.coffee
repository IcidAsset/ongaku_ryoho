class OngakuRyoho.Classes.Models.Source extends Backbone.Model

  get_file_list: () ->
    url = "#{this.url()}/file_list"

    $.get(url, (response) ->
      console.log(response)
    )



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
    this.get_file_list()

    promise.resolve()
