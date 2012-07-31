###

     ____                    __            ____              __
    / __ \____  ____ _____ _/ /____  __   / __ \__  ______  / /_  ____
   / / / / __ \/ __ `/ __ `/ #_ / / / /  / /_/ / / / / __ \/ __ \/ __ \
  / /_/ / / / / /_/ / /_/ / ,< / /_/ /  / _, _/ /_/ / /_/ / / / / /_/ /
  \____/_/ /_/\__, /\__,_/_/|_|\__,_/  /_/ |_|\__, /\____/_/ /_/\____/
             /____/                          /____/


  Main JS file with a touch of sprockets (.*)

###

#= require 'zepto'
#= require 'underscore'
#= require 'backbone'
#= require 'backbone_rails_sync'
#= require 'handlebars'
#= require 'soundmanager2/soundmanager2'
#= provide 'soundmanager2/dependencies'
#= require 'jsdeferred'
#= require 'spin'

#= require './application/helpers'
#= require './application/ongaku_ryoho'



soundManager.setup
  url: soundManagerFlashURL
  flashVersion: 9
  useFlashBlock: false
  debugMode: false
  flash9Options: { usePeakData: true }



Zepto ->

  # elements
  $controller       = $('#controller')
  $playlist         = $('#playlist')
  $source_manager   = $('#source-manager')
  $message_center   = $('#message-center')
  $visualizations   = $('#visualizations')
  $special_filters  = $('#special-filters')

  # helpers
  Helpers.initialize_before()

  # make new people
  颪.SoundGuy             = new OngakuRyoho.Classes.People.SoundGuy

  # backbone models
  颪.Controller           = new OngakuRyoho.Classes.Models.Controller

  # backbone collections
  颪.Tracks               = new OngakuRyoho.Classes.Collections.Tracks
  颪.Sources              = new OngakuRyoho.Classes.Collections.Sources
  颪.Messages             = new OngakuRyoho.Classes.Collections.Messages
  颪.Favourites           = new OngakuRyoho.Classes.Collections.Favourites

  # backbone views
  颪.MessageCenterView    = new OngakuRyoho.Classes.Views.MessageCenter({ el: $message_center })
  颪.VisualizationsView   = new OngakuRyoho.Classes.Views.Visualizations({ el: $visualizations })

  颪.ControllerView       = new OngakuRyoho.Classes.Views.Controller({ el: $controller })
  颪.PlaylistView         = new OngakuRyoho.Classes.Views.Playlist({ el: $playlist })
  颪.SourceManagerView    = new OngakuRyoho.Classes.Views.SourceManager({ el: $source_manager })

  # teach people
  颪.SoundGuy.learn_basics
    controller: 颪.Controller
    tracks: 颪.Tracks
    controller_view: 颪.ControllerView
    visualizations_view: 颪.VisualizationsView
    playlist_view: 颪.PlaylistView

  # helpers
  Helpers.initialize_after()
