class OngakuRyoho.Classes.Machinery.MessageCenter

  #
  #  Mouse event handlers
  #
  message_click_handler: (e) =>
    $t = $(e.currentTarget)

    # check
    return if $t.hasClass("loading")

    # set
    cid = $t.attr("rel")
    message = @group.collection.find (m) -> m.cid is cid

    # remove message
    @group.collection.remove(message)
