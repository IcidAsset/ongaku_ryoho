class OngakuRyoho.Classes.Models.Source extends Backbone.Model

  process: () ->
    promise = new RSVP.Promise()

    console.log(this.attributes)
    promise.resolve()

    # return
    promise
