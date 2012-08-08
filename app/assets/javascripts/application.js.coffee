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
#= require 'jsdeferred'
#= require 'spin'

#= require './application/backbone_extensions'
#= require './application/helpers'
#= require './application/ongaku_ryoho'



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
  ℰ.SoundGuy             = new OngakuRyoho.Classes.People.SoundGuy

  # backbone models
  ℰ.Controller           = new OngakuRyoho.Classes.Models.Controller

  # backbone collections
  ℰ.Tracks               = new OngakuRyoho.Classes.Collections.Tracks
  ℰ.Sources              = new OngakuRyoho.Classes.Collections.Sources
  ℰ.Messages             = new OngakuRyoho.Classes.Collections.Messages
  ℰ.Favourites           = new OngakuRyoho.Classes.Collections.Favourites

  # backbone views
  ℰ.MessageCenterView    = new OngakuRyoho.Classes.Views.MessageCenter({ el: $message_center })
  ℰ.VisualizationsView   = new OngakuRyoho.Classes.Views.Visualizations({ el: $visualizations })

  ℰ.ControllerView       = new OngakuRyoho.Classes.Views.Controller({ el: $controller })
  ℰ.PlaylistView         = new OngakuRyoho.Classes.Views.Playlist({ el: $playlist })
  ℰ.SourceManagerView    = new OngakuRyoho.Classes.Views.SourceManager({ el: $source_manager })

  # teach people
  ℰ.SoundGuy.learn_basics
    controller: ℰ.Controller
    tracks: ℰ.Tracks
    controller_view: ℰ.ControllerView
    visualizations_view: ℰ.VisualizationsView
    playlist_view: ℰ.PlaylistView

  # helpers
  Helpers.initialize_after()
