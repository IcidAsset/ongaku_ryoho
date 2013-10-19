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

    # get track and add it to the queue
    track = OngakuRyoho.RecordBox.Tracks.collection.get(id)
    OngakuRyoho.Engines.Queue.add_to_next(track) if track
