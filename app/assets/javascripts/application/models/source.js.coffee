class OngakuRyoho.Classes.Models.Source extends Backbone.Model

  poll_for_busy_state: () =>
    promise = new RSVP.Promise()
    tries = 0
    max_tries = 60 # 5 minutes

    # success
    success = () =>
      if this.get("busy") and tries < max_tries
        exec()
      else
        promise.resolve()

      tries++

    # fetch
    fetch = () =>
      this.fetch({ success: success })

    # exec
    exec = () ->
      _.delay(fetch, 5000)

    # go
    exec()

    # promise
    return promise
