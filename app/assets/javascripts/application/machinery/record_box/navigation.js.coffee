class OngakuRyoho.Classes.Machinery.RecordBox.Navigation

  #
  #  Switches
  #
  toggle_queue: (e) =>
    vsm = OngakuRyoho.People.ViewStateManager
    if vsm.get_queue_status() is off then vsm.set_queue_status(on)
    else vsm.set_queue_status(off)



  toggle_favourites: (e) =>
    vsm = OngakuRyoho.People.ViewStateManager
    if vsm.get_favourites_status() is off then vsm.set_favourites_status(on)
    else vsm.set_favourites_status(off)



  #
  #  Search
  #
  search_input_change: (e) =>
    $t = $(e.currentTarget)
    value = $t.val()

    # search
    this.search(value)



  search: (query) ->
    tracks_collection = @parent_group.Tracks.collection
    tracks_collection.filter = query
    tracks_collection.page = 1

    # fetch tracks
    tracks_collection.fetch({ success: this.search_success })

    # view state manager
    OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()



  search_success: () =>
    current_track = OngakuRyoho.People.SoundGuy.get_current_track()

    # add playing class
    @parent_group.Tracks.machine.add_playing_class_to_track(current_track) if current_track
