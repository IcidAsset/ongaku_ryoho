class OngakuRyoho.Classes.Machinery.DropZones

  #
  #  Queue
  #
  queue_dragenter: (e) =>
    @group.view.$queue.addClass("hover")



  queue_dragleave: (e) =>
    return if e.toElement is @group.view.$queue[0]
    @group.view.$queue.removeClass("hover")



  queue_dragover: (e) ->
    e.preventDefault()
    e.dataTransfer.dropEffect = "move"



  queue_drop: (e) =>
    id = parseInt(e.dataTransfer.getData("text/plain"), 10)

    # remove hover class
    @group.view.$queue.removeClass("hover")

    # get track
    track = OngakuRyoho.RecordBox.Tracks.collection.get(id)

    # add message
    message = new OngakuRyoho.Classes.Models.Message
      text: "<span class=\"icon\" data-icon=\"&#128340;\"></span>
            #{track.get('artist')} - #{track.get('title')}"

    OngakuRyoho.MessageCenter.collection.add(message) if track

    # remove message
    setTimeout(() ->
      OngakuRyoho.MessageCenter.collection.remove(message)
      message = null
    , 1500) if track

    # add to queue
    OngakuRyoho.Engines.Queue.add_to_next(track)
