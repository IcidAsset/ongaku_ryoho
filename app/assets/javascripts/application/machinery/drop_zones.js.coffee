class OngakuRyoho.Classes.Machinery.DropZones

  #
  #  Queue
  #
  queue_pointerdragenter: (e) =>
    @group.view.$queue.addClass("hover")



  queue_pointerdragleave: (e) =>
    return if e.toElement is @group.view.$queue[0]
    @group.view.$queue.removeClass("hover")



  queue_pointerdrop: (e) =>
    id = OngakuRyoho.RecordBox.Tracks.view.dragged_track_element.getAttribute("rel")
    id = parseInt(id, 10)

    # remove hover class
    @group.view.$queue.removeClass("hover")

    # get track and add it to the queue
    track = OngakuRyoho.RecordBox.Tracks.collection.get(id)
    OngakuRyoho.Engines.Queue.add_to_next(track) if track
