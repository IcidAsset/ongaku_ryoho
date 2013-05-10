class OngakuRyoho.Classes.Machinery.RecordBox.Navigation

  #
  #  Switches
  #
  toggle_queue: (e) =>
    vsm = OngakuRyoho.People.ViewStateManager
    if vsm.get_queue_status() is off then vsm.set_queue_status(on)
    else vsm.set_queue_status(off)
