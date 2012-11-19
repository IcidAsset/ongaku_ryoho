class OngakuRyoho.Classes.Routers.Default extends Backbone.Router

  routes:
    "queue" : "queue"



  #
  #  Initialize
  #
  initialize: () ->
    Backbone.history.start()



  #
  #  Queue
  #
  queue: () ->
    OngakuRyoho.Playlist.Navigation.machine.show_queue()
